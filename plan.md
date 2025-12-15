# Expense App Backend Architecture & Implementation Plan

## Architecture Overview

**Mobile App (Flutter):**
- Local Database: SQLite (sqflite) for expense data storage
- GetStorage: For user preferences, auth tokens, settings
- SMS Reading: flutter_sms plugin for reading SMS messages
- Sync: Background sync on app open, manual sync option

**Backend (Node.js):**
- Database: MongoDB for user accounts, expenses, SMS logs
- API: RESTful API with Express.js
- Authentication: JWT tokens
- Sync: Accept expenses from mobile, handle approval/rejection

## Database Schema Design

### MongoDB Collections (Server)

**users**
```javascript
{
  _id: ObjectId,
  email: String (unique, indexed),
  password: String (hashed),
  name: String,
  phoneNumber: String,
  createdAt: Date,
  updatedAt: Date,
  settings: {
    country: String,
    currency: String,
    budgetAlerts: Boolean,
    monthlyBudget: Number
  }
}
```

**expenses**
```javascript
{
  _id: ObjectId,
  userId: ObjectId (indexed),
  title: String,
  amount: Number,
  category: String,
  date: Date (indexed),
  description: String,
  source: String, // 'manual' | 'sms' | 'email'
  smsId: String, // Reference to sms_messages if from SMS
  status: String, // 'approved' | 'pending' | 'rejected'
  syncedAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

**sms_messages**
```javascript
{
  _id: ObjectId,
  userId: ObjectId (indexed),
  messageId: String (unique),
  sender: String,
  body: String,
  receivedAt: Date,
  parsedData: {
    amount: Number,
    merchant: String,
    date: Date,
    category: String,
    confidence: Number // 0-1
  },
  status: String, // 'pending' | 'approved' | 'rejected' | 'ignored'
  expenseId: ObjectId, // If approved and expense created
  createdAt: Date
}
```

### SQLite Schema (Mobile)

**expenses** table
```sql
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  description TEXT,
  source TEXT DEFAULT 'manual',
  sms_id TEXT,
  status TEXT DEFAULT 'approved',
  synced INTEGER DEFAULT 0, -- 0 = not synced, 1 = synced
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

**sms_messages** table
```sql
CREATE TABLE sms_messages (
  id TEXT PRIMARY KEY,
  message_id TEXT UNIQUE NOT NULL,
  sender TEXT NOT NULL,
  body TEXT NOT NULL,
  received_at TEXT NOT NULL,
  parsed_amount REAL,
  parsed_merchant TEXT,
  parsed_date TEXT,
  parsed_category TEXT,
  confidence REAL,
  status TEXT DEFAULT 'pending',
  expense_id TEXT,
  created_at TEXT NOT NULL
);
```

**sync_queue** table
```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  expense_id TEXT,
  sms_id TEXT,
  action TEXT NOT NULL, -- 'create' | 'update' | 'delete' | 'reject'
  synced INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
);
```

## Implementation Steps

### Phase 1: Local Database Setup (Flutter)

1. **Add Dependencies**
   - Add `sqflite`, `path`, `path_provider` to pubspec.yaml
   - Update ExpenseRepository to use SQLite instead of GetStorage

2. **Create Database Helper**
   - File: `lib/data/database/database_helper.dart`
   - Initialize SQLite database
   - Create tables (expenses, sms_messages, sync_queue)
   - Migration support

3. **Update ExpenseRepository**
   - File: `lib/data/repositories/expense_repository.dart`
   - Replace GetStorage with SQLite operations
   - Add sync status tracking
   - Add methods: `getUnsyncedExpenses()`, `markAsSynced()`

4. **Create SMS Repository**
   - File: `lib/data/repositories/sms_repository.dart`
   - Methods: `saveSMS()`, `getPendingSMS()`, `updateSMSStatus()`

### Phase 2: Authentication System

1. **Create Auth Models**
   - File: `lib/data/models/user_model.dart`
   - File: `lib/data/models/auth_response_model.dart`

2. **Create Auth Repository**
   - File: `lib/data/repositories/auth_repository.dart`
   - Methods: `signUp()`, `signIn()`, `signOut()`, `getCurrentUser()`
   - Store JWT token in GetStorage

3. **Create Auth Controller**
   - File: `lib/controllers/auth_controller.dart`
   - Handle login state, user session
   - Auto-login on app start if token exists

4. **Update Sign In/Sign Up Screens**
   - Connect to AuthController
   - Handle API calls
   - Store auth token

5. **Create API Service**
   - File: `lib/services/api_service.dart`
   - Base HTTP client with interceptors
   - JWT token injection
   - Error handling

### Phase 3: SMS Reading & Parsing

1. **Add SMS Permissions**
   - Update AndroidManifest.xml for SMS read permission
   - Add permission_handler package
   - Request permissions on first launch

2. **Create SMS Service**
   - File: `lib/services/sms_service.dart`
   - Read SMS messages using flutter_sms or sms package
   - Filter SMS by sender (banks, merchants)
   - Save to local database

3. **Create SMS Parser**
   - File: `lib/services/sms_parser.dart`
   - Parse common SMS formats (Pakistani banks, international)
   - Extract: amount, merchant, date, category
   - Confidence scoring
   - Pattern matching with regex

4. **Create SMS Controller**
   - File: `lib/controllers/sms_controller.dart`
   - Monitor SMS inbox
   - Parse and save SMS
   - Show pending expenses for approval

5. **Create Approval Screen**
   - File: `lib/views/screens/expense_approval_screen.dart`
   - List pending SMS expenses
   - Approve/reject actions
   - Edit before approval

### Phase 4: Backend API (Node.js)

1. **Project Structure**
   ```
   server/
   ├── src/
   │   ├── controllers/
   │   ├── models/
   │   ├── routes/
   │   ├── middleware/
   │   ├── services/
   │   └── config/
   ├── package.json
   └── .env
   ```

2. **Authentication Endpoints**
   - POST `/api/auth/signup` - User registration
   - POST `/api/auth/login` - User login
   - POST `/api/auth/refresh` - Refresh token
   - GET `/api/auth/me` - Get current user

3. **Expense Endpoints**
   - POST `/api/expenses` - Create/update expenses (bulk sync)
   - GET `/api/expenses` - Get user expenses (with filters)
   - DELETE `/api/expenses/:id` - Delete expense
   - PUT `/api/expenses/:id` - Update expense

4. **SMS Endpoints**
   - POST `/api/sms` - Sync SMS messages
   - PUT `/api/sms/:id/status` - Update SMS status
   - DELETE `/api/sms/:id` - Delete rejected SMS

5. **Sync Endpoint**
   - POST `/api/sync` - Bulk sync endpoint
     - Accepts: expenses, sms_messages, deletions
     - Returns: server-side updates if any

### Phase 5: Sync Mechanism

1. **Create Sync Service**
   - File: `lib/services/sync_service.dart`
   - Methods: `syncAll()`, `syncExpenses()`, `syncSMS()`
   - Handle conflicts (server wins or last-write-wins)
   - Queue failed syncs for retry

2. **Update ExpenseController**
   - Add sync on app start
   - Add sync after CRUD operations
   - Show sync status indicator

3. **Background Sync**
   - Sync on app open (main.dart)
   - Sync on network reconnect
   - Manual sync button in settings

### Phase 6: Data Models Updates

1. **Update ExpenseModel**
   - Add: `source`, `smsId`, `status`, `synced` fields
   - Update toJson/fromJson for new fields

2. **Create SMSMessageModel**
   - File: `lib/data/models/sms_message_model.dart`

3. **Create SyncQueueModel**
   - File: `lib/data/models/sync_queue_model.dart`

## Key Files to Create/Modify

### Flutter App
- `lib/data/database/database_helper.dart` (NEW)
- `lib/data/repositories/sms_repository.dart` (NEW)
- `lib/data/repositories/auth_repository.dart` (NEW)
- `lib/data/models/user_model.dart` (NEW)
- `lib/data/models/sms_message_model.dart` (NEW)
- `lib/controllers/auth_controller.dart` (NEW)
- `lib/controllers/sms_controller.dart` (NEW)
- `lib/services/api_service.dart` (NEW)
- `lib/services/sms_service.dart` (NEW)
- `lib/services/sms_parser.dart` (NEW)
- `lib/services/sync_service.dart` (NEW)
- `lib/data/repositories/expense_repository.dart` (MODIFY)
- `lib/data/models/expense_model.dart` (MODIFY)
- `lib/views/screens/sign_in_screen.dart` (MODIFY)
- `lib/views/screens/sign_up_screen.dart` (MODIFY)
- `lib/main.dart` (MODIFY - add sync on start)
- `pubspec.yaml` (MODIFY - add dependencies)
- `android/app/src/main/AndroidManifest.xml` (MODIFY - add SMS permission)

### Node.js Backend
- `server/src/config/database.js` (NEW - MongoDB connection)
- `server/src/models/User.js` (NEW)
- `server/src/models/Expense.js` (NEW)
- `server/src/models/SMSMessage.js` (NEW)
- `server/src/controllers/authController.js` (NEW)
- `server/src/controllers/expenseController.js` (NEW)
- `server/src/controllers/smsController.js` (NEW)
- `server/src/routes/authRoutes.js` (NEW)
- `server/src/routes/expenseRoutes.js` (NEW)
- `server/src/routes/smsRoutes.js` (NEW)
- `server/src/middleware/authMiddleware.js` (NEW)
- `server/src/services/smsParserService.js` (NEW - server-side parsing if needed)
- `server/src/app.js` (NEW - Express app setup)
- `server/package.json` (NEW)

## Dependencies

### Flutter
- `sqflite: ^2.3.0` - SQLite database
- `path_provider: ^2.1.1` - File system paths
- `http: ^1.1.0` - HTTP client
- `dio: ^5.4.0` - Advanced HTTP client (alternative to http)
- `flutter_sms: ^2.0.0` or `sms: ^0.2.3` - SMS reading
- `permission_handler: ^11.0.1` - Runtime permissions
- `jwt_decoder: ^2.0.1` - JWT token handling

### Node.js
- `express: ^4.18.2` - Web framework
- `mongoose: ^8.0.0` - MongoDB ODM
- `bcryptjs: ^2.4.3` - Password hashing
- `jsonwebtoken: ^9.0.2` - JWT tokens
- `dotenv: ^16.3.1` - Environment variables
- `cors: ^2.8.5` - CORS middleware
- `express-validator: ^7.0.1` - Input validation

## Security Considerations

1. **Password Hashing**: Use bcrypt with salt rounds (10-12)
2. **JWT Tokens**: Short-lived access tokens (15min) + refresh tokens (7 days)
3. **SMS Permissions**: Only request when user enables feature
4. **Data Encryption**: Encrypt sensitive data in SQLite (optional)
5. **API Security**: Rate limiting, input validation, SQL injection prevention
6. **HTTPS**: All API calls over HTTPS only

## Testing Strategy

1. **Unit Tests**: SMS parser, expense calculations
2. **Integration Tests**: API endpoints, database operations
3. **E2E Tests**: Full sync flow, SMS to expense conversion

## Future Enhancements

- Email receipt parsing (Gmail API)
- Budget alerts and notifications
- Export to CSV/PDF
- Multi-currency support
- Recurring expenses
- Expense sharing/collaboration


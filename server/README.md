# Expense App Backend Server

Node.js backend server for the Expense Tracking App using Express.js and MongoDB.

## Setup Instructions

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Configure Environment Variables**
   - Copy `.env.example` to `.env`
   - Update the values in `.env`:
     ```
     PORT=3000
     MONGODB_URI=mongodb://localhost:27017/expense_app
     JWT_SECRET=your-super-secret-jwt-key
     JWT_REFRESH_SECRET=your-super-secret-refresh-key
     ```

3. **Start MongoDB**
   - Make sure MongoDB is running on your system
   - Default connection: `mongodb://localhost:27017`

4. **Run the Server**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

## API Endpoints

### Authentication

- `POST /api/auth/signup` - Register a new user
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe",
    "phoneNumber": "+1234567890"
  }
  ```

- `POST /api/auth/login` - Login user
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```

- `GET /api/auth/me` - Get current user (requires authentication)
  - Headers: `Authorization: Bearer <token>`

- `POST /api/auth/refresh` - Refresh access token
  ```json
  {
    "refreshToken": "<refresh_token>"
  }
  ```

## Response Format

All responses follow this format:

**Success:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

**Error:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": [ ... ] // Optional validation errors
}
```

## Development

- Uses ES6 modules (import/export)
- MongoDB with Mongoose ODM
- JWT authentication
- Express-validator for input validation
- CORS enabled for cross-origin requests


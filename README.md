# Expense Tracker App

A Flutter expense tracking application built with GetX state management, following best practices and modern Flutter architecture.

## Features

- ✅ Add, edit, and delete expenses
- ✅ Categorize expenses (Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other)
- ✅ View total expenses and expenses by category
- ✅ Local storage using GetStorage
- ✅ Material Design 3 UI with dark mode support
- ✅ Clean architecture with separation of concerns

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── theme/           # Theme configuration
│   └── utils/           # Utility functions
├── data/
│   ├── models/          # Data models
│   └── repositories/     # Data access layer
├── controllers/         # GetX controllers (state management)
├── views/
│   ├── screens/         # App screens/pages
│   └── widgets/         # Reusable widgets
├── routes/              # Route definitions
└── services/           # Business logic services
```

## Tech Stack

- **Flutter**: ^3.8.1
- **GetX**: ^4.6.6 (State Management)
- **GetStorage**: ^2.1.1 (Local Storage)
- **Intl**: ^0.19.0 (Internationalization)
- **UUID**: ^4.5.1 (Unique ID generation)

## Android Configuration

- **Kotlin**: 2.1.0
- **Gradle**: 8.12
- **Android Gradle Plugin**: 8.7.3
- **Min SDK**: Flutter default
- **Target SDK**: Flutter default

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Architecture

The app follows a clean architecture pattern:

- **Models**: Data structures representing expenses
- **Repositories**: Handle data persistence and retrieval
- **Controllers**: Manage state and business logic using GetX
- **Views**: UI components (screens and widgets)
- **Routes**: Navigation configuration

## Best Practices Implemented

✅ Separation of concerns (Models, Repositories, Controllers, Views)
✅ Reactive state management with GetX
✅ Local storage for data persistence
✅ Material Design 3 theming
✅ Error handling with user-friendly messages
✅ Form validation
✅ Type-safe code with proper null safety
✅ Modern Flutter patterns (const constructors, super parameters)

## Future Enhancements

- [ ] Edit expense functionality
- [ ] Filter and search expenses
- [ ] Export expenses to CSV/PDF
- [ ] Charts and graphs for expense visualization
- [ ] Budget tracking
- [ ] Recurring expenses
- [ ] Multi-currency support

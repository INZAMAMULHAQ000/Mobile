# Apartment Management Mobile App

A comprehensive Flutter + Dart mobile application for managing multiple apartments, rooms, guest contracts, rent collection, expenses, and profit/loss analytics.

## Features

- **Apartment & Room Management**: Add, edit, and manage apartments and rooms with real-time status tracking
- **Guest & Contract Management**: Complete guest profiles with contract tracking and document management
- **Automated Notifications**: Contract expiry warnings and rent overdue notifications
- **Financial Tracking**: Income and expense management with categorized transactions
- **Analytics & Reports**: Visual charts and financial analytics with PDF/Excel export
- **Role-Based Access**: Admin, Manager, and Viewer roles with appropriate permissions
- **Real-time Sync**: Firebase Firestore for real-time data synchronization

## Tech Stack

- **Frontend**: Flutter 3.x+ with Dart 3.x+
- **State Management**: Riverpod
- **Backend**: Firebase (Firestore, Authentication, Storage, Cloud Functions, Cloud Messaging)
- **UI/UX**: Material 3 Design System
- **Charts**: fl_chart for financial visualizations
- **Export**: PDF and Excel generation capabilities

## Project Structure

```
Mobile/
├── lib/
│   ├── core/                    # Core utilities and constants
│   │   ├── constants/
│   │   ├── utils/
│   │   ├── themes/
│   │   ├── services/
│   │   └── router/
│   ├── models/                  # Data models
│   │   ├── apartment.dart
│   │   ├── guest.dart
│   │   ├── contract.dart
│   │   ├── transaction.dart
│   │   ├── user.dart
│   │   └── notification.dart
│   ├── providers/               # Riverpod state management
│   │   ├── auth_provider.dart
│   │   ├── apartment_provider.dart
│   │   ├── guest_provider.dart
│   │   └── finance_provider.dart
│   ├── screens/                 # UI screens
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── apartments/
│   │   ├── guests/
│   │   ├── finances/
│   │   └── reports/
│   ├── widgets/                 # Reusable UI components
│   │   ├── common/
│   │   ├── forms/
│   │   └── charts/
│   └── main.dart
├── functions/                   # Firebase Cloud Functions
├── firebase/                    # Firebase configuration
├── assets/                      # Images, fonts, etc.
└── test/                        # Unit and widget tests
```

## Getting Started

### Prerequisites

- Flutter SDK 3.13.0 or higher
- Dart 3.1.0 or higher
- Firebase project with Blaze plan (for Cloud Functions)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password and Google Sign-In)
   - Enable Firestore Database
   - Enable Firebase Storage
   - Enable Cloud Functions
   - Enable Cloud Messaging

4. **Configure Firebase**
   - Download the configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Update `lib/firebase/firebase_options.dart` with your Firebase configuration
   - Deploy Firestore indexes and security rules:
     ```bash
     firebase deploy --only firestore
     ```

5. **Deploy Cloud Functions**
   ```bash
   cd functions
   npm install
   cd ..
   firebase deploy --only functions
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Configuration

### Security Rules

The app includes comprehensive Firebase security rules that enforce:

- **Role-based access control** for all collections
- **User-based data isolation**
- **Input validation** at the database level
- **File upload restrictions** for Storage

### Cloud Functions

The app includes the following Cloud Functions:

1. **checkExpiringContracts** (Daily trigger)
   - Checks for contracts expiring within 15 days
   - Creates notifications for admin/manager users
   - Sends push notifications via FCM

2. **generateMonthlyReport** (HTTP callable)
   - Aggregates financial data for a specified month/year
   - Groups expenses by category
   - Returns comprehensive report data

3. **sendPushNotification** (HTTP callable)
   - Sends targeted push notifications to users
   - Requires admin/manager permissions
   - Creates in-app notifications

4. **cleanupOldNotifications** (Daily trigger)
   - Removes notifications older than 30 days
   - Maintains database performance

## Data Models

### User
- Basic user information with role-based permissions
- Roles: Admin, Manager, Viewer

### Apartment
- Apartment details with location and total rooms
- Soft delete support with isActive flag

### Room
- Room details linked to apartments
- Status tracking: vacant, occupied, maintenance

### Guest
- Guest profiles with contact information
- Document upload support (ID proof, photos)

### Contract
- Rental contracts with date tracking
- Automatic expiry detection
- Document storage support

### Transaction
- Financial transactions (income/expense)
- Categorized expense tracking
- Receipt upload support

## User Roles & Permissions

### Admin
- Full access to all features
- User management capabilities
- Can manage apartments, guests, finances
- Can view and manage all reports

### Manager
- Can manage apartments and guests
- Can manage financial transactions
- Can view reports
- Cannot manage users

### Viewer
- Read-only access to dashboard and reports
- Cannot modify any data
- Limited to viewing information

## Development

### Code Generation

The app uses code generation for some providers. Run:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/user_test.dart

# Run tests with coverage
flutter test --coverage
```

### Build

```bash
# Debug build
flutter build apk --debug

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release
```

## Contributing

1. Follow the existing code style and patterns
2. Write tests for new features
3. Update documentation for significant changes
4. Ensure all tests pass before submitting PRs

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.

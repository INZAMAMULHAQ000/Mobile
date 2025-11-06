class AppConstants {
  // App Information
  static const String appName = 'Apartment Management';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String apiTimeout = '30000';
  static const int maxRetryAttempts = 3;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Form Validation
  static const int minPasswordLength = 8;
  static const int maxPhoneNumberLength = 15;
  static const int maxNameLength = 100;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];
  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String storageDateFormat = 'yyyy-MM-dd';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String storageDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Currency
  static const String currencySymbol = '\$';
  static const int decimalPlaces = 2;

  // Notification Settings
  static const int contractExpiryDays = 15;
  static const Duration notificationCheckInterval = Duration(hours: 24);

  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100; // Maximum number of items to cache
}

class AppRoutes {
  static const String login = '/auth/login';
  static const String dashboard = '/dashboard';
  static const String apartments = '/apartments';
  static const String guests = '/guests';
  static const String finance = '/finance';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

class AppStrings {
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';
  static const String noData = 'No data available';
  static const String retry = 'Retry';

  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginWithGoogle = 'Login with Google';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalApartments = 'Total Apartments';
  static const String totalRooms = 'Total Rooms';
  static const String occupied = 'Occupied';
  static const String vacant = 'Vacant';
  static const String monthlyIncome = 'Monthly Income';
  static const String monthlyExpense = 'Monthly Expense';
  static const String expiringContracts = 'Expiring Contracts';
  static const String recentActivity = 'Recent Activity';

  // Apartments
  static const String apartments = 'Apartments';
  static const String addApartment = 'Add Apartment';
  static const String editApartment = 'Edit Apartment';
  static const String apartmentName = 'Apartment Name';
  static const String location = 'Location';
  static const String description = 'Description';
  static const String rooms = 'Rooms';
  static const String addRoom = 'Add Room';
  static const String roomNumber = 'Room Number';
  static const String floor = 'Floor';
  static const String rentAmount = 'Rent Amount';
  static const String status = 'Status';

  // Guests
  static const String guests = 'Guests';
  static const String addGuest = 'Add Guest';
  static const String editGuest = 'Edit Guest';
  static const String guestName = 'Guest Name';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String idProof = 'ID Proof';
  static const String contract = 'Contract';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String deposit = 'Deposit';

  // Finance
  static const String finance = 'Finance';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String description = 'Description';
  static const String paymentMethod = 'Payment Method';
  static const String receipt = 'Receipt';
  static const String addTransaction = 'Add Transaction';
  static const String rentCollection = 'Rent Collection';

  // Reports
  static const String reports = 'Reports';
  static const String generateReport = 'Generate Report';
  static const String export = 'Export';
  static const String profitLoss = 'Profit & Loss';
  static const String activeGuests = 'Active Guests';
  static const String contractExpiry = 'Contract Expiry';
  static const String monthlyReport = 'Monthly Report';

  // Validation Messages
  static const String required = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String selectDate = 'Please select a date';

  // Status
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String expired = 'Expired';
  static const String terminated = 'Terminated';
  static const String maintenance = 'Maintenance';
  static const String occupied = 'Occupied';
  static const String vacant = 'Vacant';
}

class RoomStatus {
  static const String vacant = 'vacant';
  static const String occupied = 'occupied';
  static const String maintenance = 'maintenance';
}

class ContractStatus {
  static const String active = 'active';
  static const String expired = 'expired';
  static const String terminated = 'terminated';
}

class UserRole {
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String viewer = 'viewer';
}

class TransactionType {
  static const String income = 'income';
  static const String expense = 'expense';
}

class TransactionCategory {
  // Income Categories
  static const String rent = 'rent';
  static const String deposit = 'deposit';
  static const String otherIncome = 'other_income';

  // Expense Categories
  static const String utilities = 'utilities';
  static const String maintenance = 'maintenance';
  static const String repairs = 'repairs';
  static const String staff = 'staff';
  static const String taxes = 'taxes';
  static const String insurance = 'insurance';
  static const String otherExpense = 'other_expense';
}

class NotificationType {
  static const String contractExpiry = 'contract_expiry';
  static const String rentOverdue = 'rent_overdue';
  static const String maintenance = 'maintenance';
  static const String payment = 'payment';
}

class PaymentMethod {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String online = 'online';
  static const String check = 'check';
}
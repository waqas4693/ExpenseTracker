class ApiConstants {
  // Base URL - Update this with your server URL
  // For Android emulator, use: http://10.0.2.2:3000/api
  // For iOS simulator, use: http://localhost:3000/api
  // For physical device, use your computer's IP: http://192.168.x.x:3000/api
  // static const String baseUrl = 'http://10.80.164.71:3002/api';
  static const String baseUrl = 'https://expense-tracker-zeta-one-24.vercel.app/api';

  // Auth Endpoints
  static const String signUp = '/auth/signup';
  static const String signIn = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String getMe = '/auth/me';

  // Expense Endpoints
  static const String expenses = '/expenses';
  static const String expensesBulk = '/expenses/bulk';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
}

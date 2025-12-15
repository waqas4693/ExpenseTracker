import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final GetStorage _storage = GetStorage();

  Future<AuthResponseModel> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.signUp,
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        final authResponse = AuthResponseModel.fromJson(data);

        // Store tokens and user data
        await _storage.write(ApiConstants.tokenKey, authResponse.token);
        await _storage.write(
          ApiConstants.refreshTokenKey,
          authResponse.refreshToken,
        );
        await _storage.write(ApiConstants.userKey, authResponse.user.toJson());

        return authResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Sign up failed');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ?? e.message ?? 'Sign up failed';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<AuthResponseModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.signIn,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final authResponse = AuthResponseModel.fromJson(data);

        // Store tokens and user data
        await _storage.write(ApiConstants.tokenKey, authResponse.token);
        await _storage.write(
          ApiConstants.refreshTokenKey,
          authResponse.refreshToken,
        );
        await _storage.write(ApiConstants.userKey, authResponse.user.toJson());

        return authResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Sign in failed');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ?? e.message ?? 'Sign in failed';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConstants.getMe);

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get user');
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage =
            e.response?.data['message'] ?? e.message ?? 'Failed to get user';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _storage.remove(ApiConstants.tokenKey);
    await _storage.remove(ApiConstants.refreshTokenKey);
    await _storage.remove(ApiConstants.userKey);
  }

  bool isLoggedIn() {
    return _storage.read<String>(ApiConstants.tokenKey) != null;
  }

  UserModel? getStoredUser() {
    final userData = _storage.read<Map<String, dynamic>>(ApiConstants.userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}

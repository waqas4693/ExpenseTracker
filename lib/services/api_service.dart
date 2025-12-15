import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  late Dio _dio;
  final GetStorage _storage = GetStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read<String>(ApiConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            _handleTokenRefresh(error, handler);
          } else {
            return handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _handleTokenRefresh(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final refreshToken = _storage.read<String>(ApiConstants.refreshTokenKey);
      if (refreshToken != null) {
        final response = await _dio.post(
          ApiConstants.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          final data = response.data['data'] as Map<String, dynamic>;
          await _storage.write(ApiConstants.tokenKey, data['token']);
          await _storage.write(
            ApiConstants.refreshTokenKey,
            data['refreshToken'],
          );

          // Retry original request
          final opts = error.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${data['token']}';
          final cloneReq = await _dio.request(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          return handler.resolve(cloneReq);
        }
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await _storage.remove(ApiConstants.tokenKey);
      await _storage.remove(ApiConstants.refreshTokenKey);
    }
    return handler.next(error);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}

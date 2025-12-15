import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;
  final String refreshToken;

  AuthResponseModel({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

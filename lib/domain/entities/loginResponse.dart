import 'user.dart';

class LoginResponse {
  final String message;
  final User user;
  final bool hasPets;

  LoginResponse({
    required this.message,
    required this.user,
    required this.hasPets,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
      hasPets: json['hasPets'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      'hasPets': hasPets,
    };
  }
}

import 'user.dart';
import 'pet.dart';

class LoginResponse {
  final String message;
  final User user;
  final List<Pet> pets;

  LoginResponse({
    required this.message,
    required this.user,
    required this.pets,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('🔹 JSON completo recibido en LoginResponse: $json');

    final message = json['message'] ?? '';

    final userJson = json['user'];
    print('🔹 User JSON: $userJson');

    final petsJson = json['pets'] as List<dynamic>? ?? [];

    final user = User.fromJson(userJson);
    print('✅ Usuario creado: ${user.toJson()}');

    final pets = petsJson.map((petJson) {
      return Pet.fromJson(petJson);
    }).toList();

    return LoginResponse(
      message: message,
      user: user,
      pets: pets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      'pets': pets.map((pet) => pet.toJson()).toList(),
    };
  }
}

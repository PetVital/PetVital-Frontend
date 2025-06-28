import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../domain/entities/loginResponse.dart';
import '../repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class UserApi {
  final localStorageService = LocalStorageService();
  final String baseUrl = ApiConstants.baseUrl;

  Future<LoginResponse?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      body: {
        'email': email,
        'contraseña': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print(data);
      return LoginResponse.fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> register(String nombre, String apellidos, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      body: {
        'email': email,
        'contraseña': password,
        'nombres': nombre,
        'apellidos': apellidos,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> changePassword(String newPassword) async {
    final int userId = await localStorageService.getCurrentUserId();

    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/$userId/change-password/'),
      body: {
        'nueva_contraseña': newPassword,
      },
    );

    return response.statusCode == 200;
  }


  Future<bool> editProfile(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/${user.id}/'),
      body: {
        'email': user.email,
        'nombres': user.firstName,
        'apellidos': user.lastName,
      },
    );

    return response.statusCode == 200;
  }


}
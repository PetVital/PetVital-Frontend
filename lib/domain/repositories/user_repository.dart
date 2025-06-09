import '../entities/loginResponse.dart';

abstract class UserRepository {
  Future<LoginResponse?> login(String email, String password);
  Future<bool> register(String name, String lastname, String email, String password);
}
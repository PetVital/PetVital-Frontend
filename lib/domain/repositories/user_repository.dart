import '../entities/loginResponse.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<LoginResponse?> login(String email, String password);
  Future<bool> register(String name, String lastname, String email, String password);
  Future<bool> editProfile(User user);
  Future<bool> changePassword(String newPassword);
}
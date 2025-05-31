import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> login(String email, String password);
  Future<bool> register(String name, String lastname, String email, String password);
}
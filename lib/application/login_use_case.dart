import '../domain/entities/user.dart';
import '../domain/repositories/user_repository.dart';

class LoginUseCase {
  final UserRepository userRepository;

  LoginUseCase(this.userRepository);

  Future<User?> login(String email, String password) async {
    try {
      final User? user = await userRepository.login(email, password);
      return user; // Devuelve el objeto User
    } catch (e) {
      return null; // Devuelve null en caso de error
    }
  }
}
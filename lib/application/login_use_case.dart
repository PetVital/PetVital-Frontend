import '../domain/entities/loginResponse.dart';
import '../domain/repositories/user_repository.dart';
import '../data/repositories/local_storage_service.dart';
import '../data/service/notification_service.dart';

class LoginUseCase {
  final UserRepository userRepository;
  final LocalStorageService _storageService = LocalStorageService();

  LoginUseCase(this.userRepository);

  Future<LoginResponse?> login(String email, String password) async {
    try {
      final LoginResponse? loginResponse = await userRepository.login(email, password);

      await _storageService.saveUser(loginResponse!.user);

      await NotificationService.setupForUser(loginResponse.user.id);

      return loginResponse; // Devuelve el objeto User
    } catch (e) {
      return null; // Devuelve null en caso de error
    }
  }
}
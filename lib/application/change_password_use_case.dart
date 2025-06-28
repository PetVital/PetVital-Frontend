import '../domain/repositories/user_repository.dart';

class ChangePasswordUseCase {
  final UserRepository userRepository;

  ChangePasswordUseCase(this.userRepository);

  Future<bool> changePassword(String newPassword) async {
    try {
      return await userRepository.changePassword(newPassword);
    } catch (e) {
      return false;
    }
  }
}
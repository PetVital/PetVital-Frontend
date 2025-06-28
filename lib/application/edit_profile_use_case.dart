import '../domain/repositories/user_repository.dart';
import '../domain/entities/user.dart';

class EditProfileUseCase {
  final UserRepository userRepository;

  // Constructor que inicializa el repositorio
  EditProfileUseCase(this.userRepository);

  // Método para editar el perfil
  Future<bool> editProfile(User user) async {
    try {
      return await userRepository.editProfile(user);
    } catch (e) {
      return false;
    }
  }
}
import '../domain/entities/pet.dart';
import '../domain/repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository petRepository;

  UpdatePetUseCase(this.petRepository);

  Future<bool> updatePet(Pet pet) async {
    try {
      final bool updatePetResponse = await petRepository.updatePet(pet);
      return updatePetResponse;
    } catch (e) {
      return false;
    }
  }
}
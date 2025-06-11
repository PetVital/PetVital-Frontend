import '../domain/entities/pet.dart';
import '../domain/repositories/pet_repository.dart';

class DeletePetUseCase {
  final PetRepository petRepository;

  DeletePetUseCase(this.petRepository);

  Future<bool> deletePet(int petId) async {
    try {
      final bool deletePetResponse = await petRepository.deletePet(petId);
      return deletePetResponse;
    } catch (e) {
      return false;
    }
  }
}
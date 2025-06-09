import '../domain/entities/pet.dart';
import '../domain/repositories/pet_repository.dart';

class AddPetUseCase {
  final PetRepository petRepository;

  AddPetUseCase(this.petRepository);

  Future<bool> addPet(Pet pet) async {
    try {
      final bool addPetResponse = await petRepository.addPet(pet);
      return addPetResponse;
    } catch (e) {
      return false;
    }
  }
}
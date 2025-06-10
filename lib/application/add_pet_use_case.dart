import '../domain/entities/pet.dart';
import '../domain/repositories/pet_repository.dart';

class AddPetUseCase {
  final PetRepository petRepository;

  AddPetUseCase(this.petRepository);

  Future<Pet?> addPet(Pet pet) async {
    try {
      final Pet? addPetResponse = await petRepository.addPet(pet);
      return addPetResponse;
    } catch (e) {
      return null;
    }
  }
}
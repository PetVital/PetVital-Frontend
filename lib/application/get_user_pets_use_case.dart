import '../domain/entities/pet.dart';
import '../domain/repositories/pet_repository.dart';

class GetUserPetsUseCase {
  final PetRepository petRepository;

  GetUserPetsUseCase(this.petRepository);

  Future<List<Pet>?> getUserPets() async {
    try {
      final List<Pet>? pets = await petRepository.getUserPets();
      return pets;
    } catch (e) {
      return null;
    }
  }
}
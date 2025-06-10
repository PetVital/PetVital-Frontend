import '../../domain/repositories/pet_repository.dart';
import '../../domain/entities/pet.dart';
import '../api/pet_api.dart';

class PetRepositoryImpl implements PetRepository {
  final PetApi petApi;

  PetRepositoryImpl(this.petApi);

  @override
  Future<Pet?> addPet(Pet pet) async {
    return await petApi.addPet(pet);
  }

  @override
  Future<List<Pet>?> getUserPets() async{
    return await petApi.getUserPets();
  }
}
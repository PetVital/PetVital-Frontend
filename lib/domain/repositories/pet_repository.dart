import '../entities/pet.dart';

abstract class PetRepository {
  Future<Pet?> addPet(Pet pet);
  Future<List<Pet>?> getUserPets();
}
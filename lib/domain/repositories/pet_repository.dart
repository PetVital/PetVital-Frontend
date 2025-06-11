import '../entities/pet.dart';

abstract class PetRepository {
  Future<Pet?> addPet(Pet pet);
  Future<List<Pet>?> getUserPets();
  Future<bool> deletePet(int petId);
  Future<bool> updatePet(Pet pet);
}
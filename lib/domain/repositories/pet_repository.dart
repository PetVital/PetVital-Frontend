import '../entities/pet.dart';

abstract class PetRepository {
  Future<bool> addPet(Pet pet);
}
import '../domain/entities/checkup.dart';
import '../domain/repositories/checkup_repository.dart';

class GetPetCheckupsUseCase {
  final CheckupRepository checkupRepository;

  GetPetCheckupsUseCase(this.checkupRepository);

  Future<List<Checkup>?> getPetCheckups(int petId) async {
    try {
      return await checkupRepository.getPetCheckups(petId);
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }
}
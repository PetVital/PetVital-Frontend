import '../domain/entities/checkup.dart';
import '../domain/repositories/checkup_repository.dart';

class UpdateCheckupUseCase {
  final CheckupRepository checkupRepository;

  UpdateCheckupUseCase(this.checkupRepository);

  Future<bool> updateCheckup(Checkup checkup) async {
    try {
      final bool updatePetResponse = await checkupRepository.updateCheckup(checkup);
      return updatePetResponse;
    } catch (e) {
      return false;
    }
  }
}
import '../domain/entities/checkup.dart';
import '../domain/repositories/checkup_repository.dart';

class AddCheckupUseCase {
  final CheckupRepository checkupRepository;

  AddCheckupUseCase(this.checkupRepository);

  Future<bool> addcheckup(Checkup checkup) async {
    try {
      final bool response = await checkupRepository.addCheckup(checkup);
      return response;
    } catch (e) {
      return false;
    }
  }
}

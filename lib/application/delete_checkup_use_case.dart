import '../domain/repositories/checkup_repository.dart';

class DeleteCheckupUseCase {
  final CheckupRepository checkupRepository;

  DeleteCheckupUseCase(this.checkupRepository);

  Future<bool> deleteCheckup(int checkupId) async {
    try {
      final bool deleteResponse = await checkupRepository.deleteCheckup(checkupId);
      return deleteResponse;
    } catch (e) {
      return false;
    }
  }
}
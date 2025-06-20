import '../entities/checkup.dart';

abstract class CheckupRepository {
  Future<bool> addCheckup(Checkup checkup);
  Future<bool> updateCheckup(Checkup checkup);
  Future<List<Checkup>?> getPetCheckups(int petId);
  Future<bool> deleteCheckup(int checkupId);
}

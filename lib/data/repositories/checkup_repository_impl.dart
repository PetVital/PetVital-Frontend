import 'package:petvital/domain/entities/checkup.dart';
import '../../domain/repositories/checkup_repository.dart';
import '../api/checkup_api.dart';

class CheckupRepositoryImpl implements CheckupRepository {
  final CheckupApi checkupApi;

  CheckupRepositoryImpl(this.checkupApi);

  @override
  Future<bool> addCheckup(Checkup checkup) async {
    return await checkupApi.addCheckup(checkup);
  }

  @override
  Future<bool> updateCheckup(Checkup checkup) async {
    return await checkupApi.addCheckup(checkup);
  }

  @override
  Future<List<Checkup>?> getPetCheckups(int petId) async {
    return await checkupApi.getPetCheckups(petId); // ← Llamada nombrada
  }

  @override
  Future<bool> deleteCheckup(int checkupId) async {
    return await checkupApi.deleteCheck(checkupId);
  }

}
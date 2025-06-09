import '../domain/entities/homeResponse.dart';
import '../domain/repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository homeRepository;

  GetHomeDataUseCase(this.homeRepository);

  Future<HomeResponse?> getHomeData() async {
    try {
      final HomeResponse? homeResponse = await homeRepository.getHomeData();
      return homeResponse;
    } catch (e) {
      return null;
    }
  }
}
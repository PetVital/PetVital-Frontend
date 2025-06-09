import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/homeResponse.dart';
import '../api/home_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApi homeApi;

  HomeRepositoryImpl(this.homeApi);

  @override
  Future<HomeResponse?> getHomeData() async {
    return await homeApi.getHomeData();
  }
}
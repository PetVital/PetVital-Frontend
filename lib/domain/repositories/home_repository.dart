import '../entities/homeResponse.dart';

abstract class HomeRepository {
  Future<HomeResponse?> getHomeData();
}
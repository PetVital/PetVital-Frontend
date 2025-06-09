import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/homeResponse.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class HomeApi {
  final localStorageService = LocalStorageService();
  final String baseUrl = ApiConstants.baseUrl;

  Future<HomeResponse?> getHomeData() async {
    try {
      final userId = await localStorageService.getCurrentUserId();
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/home-data/?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return HomeResponse.fromJson(jsonData);
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('Excepción en getHomeData: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/pet.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class PetApi {
  final String baseUrl = ApiConstants.baseUrl;
  final localStorageService = LocalStorageService();
  Future<bool> addPet(Pet pet) async {

    final body = {
      'nombres': pet.name,
      'tipo': pet.type,
      'raza': pet.breed,
      'genero': pet.gender,
      'edad': pet.age.toString(),
      'peso': pet.weight.toString(),
      'unidad_tiempo': pet.timeUnit.toString(),
      'usuario': pet.userId
    };

    final response = await http.post(
      Uri.parse('$baseUrl/mascotas/create/'), // Asegúrate de que coincida con tu ruta real
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Pet>?> getUserPets() async {
    try {
      final userId = await localStorageService.getCurrentUserId();
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/mascotas/list/?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Pet.fromJson(item)).toList();
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print('Excepción en getUserPets: $e');
      return null;
    }
  }

}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/pet.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class PetApi {
  final String baseUrl = ApiConstants.baseUrl;
  final localStorageService = LocalStorageService();
  Future<Pet?> addPet(Pet pet) async {

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
      Uri.parse('$baseUrl/mascotas/create/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return Pet.fromJson(responseData['mascota']); // asegúrate que el backend devuelve esto
    } else {
      print('Error al crear la mascota: ${response.body}');
      return null;
    }
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

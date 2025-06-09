import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/pet.dart';
import 'common/api_constants.dart';
import '../../data/repositories/local_storage_service.dart';

class PetApi {
  final String baseUrl = ApiConstants.baseUrl;
  final LocalStorageService _storageService = LocalStorageService();

  Future<bool> addPet(Pet pet) async {
    final userId = await _storageService.getCurrentUserId();

    final body = {
      'nombres': pet.name,
      'tipo': pet.type,
      'raza': pet.breed,
      'genero': pet.gender,
      'edad': pet.age.toString(),
      'peso': pet.weight.toString(),
      'usuario': userId,
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
}

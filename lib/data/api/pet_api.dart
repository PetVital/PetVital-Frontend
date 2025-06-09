import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/pet.dart';
import 'common/api_constants.dart';

class PetApi {
  final String baseUrl = ApiConstants.baseUrl;
  Future<bool> addPet(Pet pet) async {

    final body = {
      'nombres': pet.name,
      'tipo': pet.type,
      'raza': pet.breed,
      'genero': pet.gender,
      'edad': pet.age.toString(),
      'peso': pet.weight.toString(),
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
}

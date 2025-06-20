import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/checkup.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class CheckupApi {
  final String baseUrl = ApiConstants.baseUrl;
  final localStorageService = LocalStorageService();

  Future<bool> addCheckup(Checkup checkup) async {
    try {
      final body = checkup.toJson();

      final response = await http.post(
        Uri.parse('$baseUrl/revision/create/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error al crear cita: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al crear cita: $e');
      return false;
    }
  }

  Future<bool> updatePet(Checkup checkup) async {
    final int checkupId = checkup.id;

    final body = {
      'titulo': checkup.title,
      'descripcion': checkup.description,
      'fecha': checkup.date,
      'mascota': checkup.petId,
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/revision/$checkupId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al actualizar la revision: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción en updateCheckup: $e');
      return false;
    }
  }

  Future<List<Checkup>?> getPetCheckups(int petId) async {
    try {
      // Cambiar pet_id por mascota_id para coincidir con el backend
      final uri = Uri.parse('$baseUrl/revision/list/').replace(
        queryParameters: {
          'mascota_id': petId.toString(), // Convertir a string explícitamente
        },
      );

      print('URL de consulta: $uri'); // Debug

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // Verificar si la respuesta es una lista
        if (responseData is List) {
          final List<dynamic> jsonData = responseData;
          return jsonData.map((item) => Checkup.fromJson(item)).toList();
        } else {
          print('Error: La respuesta no es una lista. Tipo: ${responseData.runtimeType}');
          print('Contenido: $responseData');
          return null;
        }
      } else {
        print('Error al obtener revisiones: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener revisiones: $e');
      return null;
    }
  }

  Future<bool> deleteCheck(int petId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/revision/$petId/'), // Asegúrate de que termina con /
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        print('Revision eliminada exitosamente.');
        return true;
      } else {
        print('Error al eliminar la revision: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción en deleteAppointment: $e');
      return false;
    }
  }
}
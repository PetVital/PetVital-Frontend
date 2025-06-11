import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/appointment.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class AppointmentApi {
  final String baseUrl = ApiConstants.baseUrl;
  final localStorageService = LocalStorageService();

  /// Crear una nueva cita
  Future<bool> addAppointment(Appointment appointment) async {
    try {
      final body = appointment.toJson();

      final response = await http.post(
        Uri.parse('$baseUrl/citas/create/'),
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

  /// Listar citas solo por usuario
  Future<List<Appointment>?> getUserAppointments() async {
    try {
      final userId = await localStorageService.getCurrentUserId();
      if (userId == null) return null;

      final uri = Uri.parse('$baseUrl/citas/list/').replace(
        queryParameters: {
          'user_id': userId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Appointment.fromJson(item)).toList();
      } else {
        print('Error al obtener citas: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener citas: $e');
      return null;
    }
  }

  Future<Appointment?> getAppointmentDetail(int appointmentId) async {
    try {
      final uri = Uri.parse('$baseUrl/citas/detail/$appointmentId/');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Appointment.fromJson(jsonData);
      } else {
        print('Error al obtener la cita: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener la cita: $e');
      return null;
    }
  }


  /// Listar citas por mascota
  Future<List<Appointment>?> getPetAppointments(int petId) async {
    try {

      final uri = Uri.parse('$baseUrl/citas/list/').replace(
        queryParameters: {
          'mascota_id': petId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Appointment.fromJson(item)).toList();
      } else {
        print('Error al obtener citas: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener citas: $e');
      return null;
    }
  }

  Future<bool> deleteAppointment(int appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/citas/$appointmentId/'), // Asegúrate de que termina con /
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        print('Cita eliminada exitosamente.');
        return true;
      } else {
        print('Error al eliminar la cita: ${response.statusCode}');
        print('Detalle: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción en deleteAppointment: $e');
      return false;
    }
  }


}

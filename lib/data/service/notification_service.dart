import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';


class NotificationService {
  static const String _oneSignalAppId = "64b1091b-6756-4760-97f2-b280b458dc49";
  static const String _oneSignalApiKey = "os_v2_app_msyqsg3hkzdwbf7swkaliwg4jej5aurgoufet657tmqzgfc5dmiulayczqua5h4xod7dsdkmvmfjeplzryletou267zshapkkn7dsdy";

  /// Programa una notificación basada en el recordatorio de la cita
  static Future<bool> scheduleAppointmentNotification({
    required String appointmentDate, // formato: yyyy-mm-dd
    required String appointmentTime, // formato: HH:mm:ss
    required String reminderType,    // '30 minutos antes', '1 hora antes', etc.
    required String title,
    required String message,
    required String petName,
    required String appointmentType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Si no hay recordatorio, no programar notificación
      if (reminderType == 'Sin recordatorio') {
        print('Sin recordatorio seleccionado, no se programa notificación');
        return true;
      }

      // Obtener el player ID del dispositivo actual
      String? playerId = OneSignal.User.pushSubscription.id;

      if (playerId == null) {
        print('No se pudo obtener el player ID');
        return false;
      }

      // Construir DateTime de la cita
      final appointmentDateTime = _buildAppointmentDateTime(appointmentDate, appointmentTime);

      // Calcular la fecha de notificación basada en el recordatorio
      final notificationDateTime = _calculateNotificationDateTime(appointmentDateTime, reminderType);

      // Verificar que la fecha de notificación sea futura
      if (notificationDateTime.isBefore(DateTime.now())) {
        print('La fecha de notificación es en el pasado, no se programa');
        return false;
      }

      // Crear el payload para la API de OneSignal
      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {'es': title},
        'contents': {'es': message},
        'send_after': notificationDateTime.toUtc().toIso8601String(),
        'data': {
          'type': 'appointment_reminder',
          'pet_name': petName,
          'appointment_type': appointmentType,
          'appointment_date': appointmentDate,
          'appointment_time': appointmentTime,
          ...?additionalData,
        },
      };

      // Enviar la notificación programada
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notificación programada exitosamente para: ${notificationDateTime.toString()}');
        print('Respuesta: ${response.body}');
        return true;
      } else {
        print('Error al programar notificación: ${response.statusCode}');
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al programar notificación: $e');
      return false;
    }
  }

  /// Construye un DateTime a partir de fecha y hora string
  static DateTime _buildAppointmentDateTime(String date, String time) {
    // date: "2024-12-25", time: "14:30:00"
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    return DateTime(
      int.parse(dateParts[0]), // año
      int.parse(dateParts[1]), // mes
      int.parse(dateParts[2]), // día
      int.parse(timeParts[0]), // hora
      int.parse(timeParts[1]), // minuto
      int.parse(timeParts[2]), // segundo
    );
  }

  /// Calcula cuándo enviar la notificación basado en el tipo de recordatorio
  static DateTime _calculateNotificationDateTime(DateTime appointmentDateTime, String reminderType) {
    switch (reminderType) {
      case '30 minutos antes':
        return appointmentDateTime.subtract(const Duration(minutes: 30));
      case '1 hora antes':
        return appointmentDateTime.subtract(const Duration(hours: 1));
      case '1 día antes':
        return appointmentDateTime.subtract(const Duration(days: 1));
      default:
        return appointmentDateTime.subtract(const Duration(minutes: 30)); // default
    }
  }

  /// Genera el mensaje personalizado para la notificación
  static String generateNotificationMessage({
    required String petName,
    required String appointmentType,
    required String reminderType,
  }) {
    String timeText = '';
    switch (reminderType) {
      case '30 minutos antes':
        timeText = 'en 30 minutos';
        break;
      case '1 hora antes':
        timeText = 'en 1 hora';
        break;
      case '1 día antes':
        timeText = 'mañana';
        break;
      default:
        timeText = 'pronto';
    }

    return '$petName tiene cita de $appointmentType $timeText. ¡No lo olvides!';
  }

  static Future<void> sendImmediateNotification({
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String? playerId = OneSignal.User.pushSubscription.id;

      if (playerId == null) {
        print('No se pudo obtener el player ID');
        return;
      }

      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {'en': title},
        'contents': {'en': message},
      };

      if (additionalData != null) {
        payload['data'] = additionalData;
      }

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notificación enviada exitosamente');
      } else {
        print('Error al enviar notificación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar notificación: $e');
    }
  }

  // Mantener método original para compatibilidad
  static Future<void> scheduleNotification({
    required DateTime dateTime,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String? playerId = OneSignal.User.pushSubscription.id;

      if (playerId == null) {
        print('No se pudo obtener el player ID');
        return;
      }

      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {'es': title},
        'contents': {'es': message},
        'send_after': dateTime.toUtc().toIso8601String(),
      };

      if (additionalData != null) {
        payload['data'] = additionalData;
      }

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notificación programada exitosamente');
      } else {
        print('Error al programar notificación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al programar notificación: $e');
    }
  }
}
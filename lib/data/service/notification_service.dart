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

      // DEBUG: Mostrar los valores recibidos
      print('=== DEBUG PARÁMETROS RECIBIDOS ===');
      print('appointmentDate recibido: $appointmentDate');
      print('appointmentTime recibido: $appointmentTime');
      print('reminderType recibido: $reminderType');

      // Construir DateTime de la cita EN ZONA HORARIA DE PERÚ
      final appointmentDateTime = _buildAppointmentDateTimeInPeru(appointmentDate, appointmentTime);

      print('DateTime de la cita construido: ${appointmentDateTime.toString()}');

      // Calcular la fecha de notificación basada en el recordatorio
      final notificationDateTime = _calculateNotificationDateTime(appointmentDateTime, reminderType);

      print('DateTime de notificación calculado: ${notificationDateTime.toString()}');

      // Verificar que la fecha de notificación sea futura (comparar en hora local)
      final nowInPeru = DateTime.now(); // Hora local del dispositivo
      if (notificationDateTime.isBefore(nowInPeru)) {
        print('La fecha de notificación es en el pasado, no se programa');
        print('Notificación programada para: ${notificationDateTime.toString()}');
        print('Hora actual: ${nowInPeru.toString()}');
        return false;
      }

      // IMPORTANTE: Ajustar para zona horaria de Perú (UTC-5)
      // Como estamos en Perú (UTC-5), necesitamos SUMAR 5 horas para que OneSignal
      // interprete correctamente la hora local como UTC
      final notificationDateTimeUTC = notificationDateTime.add(const Duration(hours: 5));

      print('=== DEBUG ZONA HORARIA ===');
      print('Cita programada (hora local): ${appointmentDateTime.toString()}');
      print('Notificación programada (hora local): ${notificationDateTime.toString()}');
      print('Notificación programada (UTC para OneSignal): ${notificationDateTimeUTC.toIso8601String()}');
      print('Hora actual (local): ${nowInPeru.toString()}');
      print('========================');

      // Crear el payload para la API de OneSignal
      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {
          'en': title,  // Inglés requerido
          'es': title   // Español adicional
        },
        'contents': {
          'en': message,  // Inglés requerido
          'es': message   // Español adicional
        },
        'send_after': notificationDateTimeUTC.toIso8601String(),
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
        print('Notificación programada exitosamente');
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

  /// Construye un DateTime en zona horaria de Perú (UTC-5)
  static DateTime _buildAppointmentDateTimeInPeru(String date, String time) {
    // date: "2024-12-25", time: "14:30:00"
    print('=== DEBUG BUILD DATETIME ===');
    print('Fecha string: $date');
    print('Hora string: $time');

    final dateParts = date.split('-');
    final timeParts = time.split(':');

    print('Año: ${dateParts[0]}, Mes: ${dateParts[1]}, Día: ${dateParts[2]}');
    print('Hora: ${timeParts[0]}, Minuto: ${timeParts[1]}, Segundo: ${timeParts[2]}');

    // Crear DateTime en hora local (asumiendo que el dispositivo está en Perú)
    final localDateTime = DateTime(
      int.parse(dateParts[0]), // año
      int.parse(dateParts[1]), // mes
      int.parse(dateParts[2]), // día
      int.parse(timeParts[0]), // hora
      int.parse(timeParts[1]), // minuto
      int.parse(timeParts[2]), // segundo
    );

    print('DateTime final construido: ${localDateTime.toString()}');
    print('===========================');

    return localDateTime;
  }

  /// Método alternativo si necesitas mayor control sobre la zona horaria
  static DateTime _buildAppointmentDateTimeInPeruExplicit(String date, String time) {
    // date: "2024-12-25", time: "14:30:00"
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    // Crear DateTime UTC y luego ajustar a Perú (UTC-5)
    final utcDateTime = DateTime.utc(
      int.parse(dateParts[0]), // año
      int.parse(dateParts[1]), // mes
      int.parse(dateParts[2]), // día
      int.parse(timeParts[0]), // hora
      int.parse(timeParts[1]), // minuto
      int.parse(timeParts[2]), // segundo
    );

    // Ajustar a hora de Perú (UTC-5 significa restar 5 horas de UTC)
    return utcDateTime.subtract(const Duration(hours: 5));
  }

  /// Calcula cuándo enviar la notificación basado en el tipo de recordatorio
  static DateTime _calculateNotificationDateTime(DateTime appointmentDateTime, String reminderType) {
    print('=== DEBUG CÁLCULO NOTIFICACIÓN ===');
    print('Fecha de cita: ${appointmentDateTime.toString()}');
    print('Tipo de recordatorio: $reminderType');

    DateTime result;

    switch (reminderType) {
      case '30 minutos antes':
        result = appointmentDateTime.subtract(const Duration(minutes: 30));
        break;
      case '1 hora antes':
        result = appointmentDateTime.subtract(const Duration(hours: 1));
        break;
      case '1 día antes':
        result = appointmentDateTime.subtract(const Duration(days: 1));
        break;
      default:
        result = appointmentDateTime.subtract(const Duration(minutes: 30)); // default
    }

    print('Fecha de notificación calculada: ${result.toString()}');
    print('===============================');

    return result;
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
        'headings': {
          'en': title,  // Inglés requerido
          'es': title   // Español adicional
        },
        'contents': {
          'en': message,  // Inglés requerido
          'es': message   // Español adicional
        },
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

  // Método mejorado con manejo correcto de zona horaria
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

      // Asegurar que enviamos la fecha correcta a OneSignal
      // Para Perú (UTC-5), sumamos 5 horas para compensar la diferencia
      final dateTimeUTC = dateTime.add(const Duration(hours: 5));

      print('=== DEBUG SCHEDULE ===');
      print('DateTime local: ${dateTime.toString()}');
      print('DateTime ajustado para OneSignal: ${dateTimeUTC.toIso8601String()}');
      print('=======================');

      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {
          'en': title,  // Inglés requerido
          'es': title   // Español adicional
        },
        'contents': {
          'en': message,  // Inglés requerido
          'es': message   // Español adicional
        },
        'send_after': dateTimeUTC.toIso8601String(),
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
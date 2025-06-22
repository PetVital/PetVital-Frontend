import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
// 🔥 Importar tu LocalStorageService en lugar de SharedPreferences
import '../repositories/local_storage_service.dart';

class NotificationService {
  static const String _oneSignalAppId = "64b1091b-6756-4760-97f2-b280b458dc49";
  static const String _oneSignalApiKey = "os_v2_app_msyqsg3hkzdwbf7swkaliwg4jej5aurgoufet657tmqzgfc5dmiulayczqua5h4xod7dsdkmvmfjeplzryletou267zshapkkn7dsdy";

  static final LocalStorageService _storage = LocalStorageService();

  /// Configura OneSignal para un nuevo usuario
  static Future<void> setupForUser(String userId) async {
    try {
      // 🔥 Obtener usuario actual desde la base de datos
      final currentUser = await _storage.getCurrentUser();
      final previousUserId = currentUser?.id;

      // Si hay un usuario anterior diferente, limpiar sus notificaciones
      if (previousUserId != null && previousUserId != userId) {
        await cancelAllScheduledNotifications();
        print('Notificaciones del usuario anterior ($previousUserId) canceladas');
      }

      // El usuario ya debe estar guardado en la base de datos antes de llamar este método
      // Si no está guardado, guardar el ID temporalmente no es necesario porque
      // tu LocalStorageService ya maneja el usuario actual

      // Configurar tags en OneSignal para identificar al usuario
      OneSignal.User.addTagWithKey('user_id', userId);

      print('OneSignal configurado para usuario: $userId');
    } catch (e) {
      print('Error al configurar OneSignal para usuario: $e');
    }
  }

  /// Limpia la sesión y cancela todas las notificaciones
  static Future<void> clearSession() async {
    try {
      // Cancelar todas las notificaciones programadas del usuario actual
      await cancelAllScheduledNotifications();

      // 🔥 Limpiar datos usando tu LocalStorageService
      // Esto limpia la tabla User y otras tablas según tu lógica de negocio
      await _storage.clearAllTablesExceptUserCredentials();

      // Remover tags de OneSignal
      OneSignal.User.removeTag('user_id');

      print('Sesión limpiada y notificaciones canceladas');
    } catch (e) {
      print('Error al limpiar sesión: $e');
    }
  }

  /// Programa una notificación y la guarda localmente para poder cancelarla
  static Future<bool> scheduleAppointmentNotification({
    required String appointmentDate,
    required String appointmentTime,
    required String reminderType,
    required String title,
    required String message,
    required String petName,
    required String appointmentType,
    required String appointmentId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (reminderType == 'Sin recordatorio') {
        print('Sin recordatorio seleccionado, no se programa notificación');
        return true;
      }

      String? playerId = OneSignal.User.pushSubscription.id;
      if (playerId == null) {
        print('No se pudo obtener el player ID');
        return false;
      }

      // 🔥 Verificar que hay un usuario activo usando LocalStorageService
      final currentUser = await _storage.getCurrentUser();
      if (currentUser == null) {
        print('No hay usuario activo, no se programa notificación');
        return false;
      }

      final appointmentDateTime = _buildAppointmentDateTimeInPeru(appointmentDate, appointmentTime);
      final notificationDateTime = _calculateNotificationDateTime(appointmentDateTime, reminderType);

      if (notificationDateTime.isBefore(DateTime.now())) {
        print('La fecha de notificación es en el pasado, no se programa');
        return false;
      }

      final notificationDateTimeUTC = notificationDateTime.add(const Duration(hours: 5));

      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {
          'en': title,
          'es': title
        },
        'contents': {
          'en': message,
          'es': message
        },
        'send_after': notificationDateTimeUTC.toIso8601String(),
        'data': {
          'type': 'appointment_reminder',
          'pet_name': petName,
          'appointment_type': appointmentType,
          'appointment_date': appointmentDate,
          'appointment_time': appointmentTime,
          'appointment_id': appointmentId,
          'user_id': currentUser.id,
          ...?additionalData,
        },
      };

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final notificationId = responseData['id'];

        // 🔥 Guardar la notificación programada usando LocalStorageService
        await _storage.saveScheduledNotification(
          notificationId: notificationId,
          appointmentId: appointmentId,
          userId: currentUser.id,
          scheduledDate: notificationDateTime.toIso8601String(),
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
          petName: petName,
          appointmentType: appointmentType,
        );

        print('Notificación programada exitosamente: $notificationId');
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

  /// Cancela una notificación específica
  static Future<bool> cancelAppointmentNotification(String appointmentId) async {
    try {
      // 🔥 Buscar la notificación en la base de datos
      final notification = await _storage.getScheduledNotificationByAppointment(appointmentId);

      if (notification == null) {
        print('No se encontró notificación para la cita: $appointmentId');
        return false;
      }

      final notificationId = notification['notification_id'] as String;

      // Cancelar en OneSignal
      final response = await http.delete(
        Uri.parse('https://onesignal.com/api/v1/notifications/$notificationId?app_id=$_oneSignalAppId'),
        headers: {
          'Authorization': 'Basic $_oneSignalApiKey',
        },
      );

      if (response.statusCode == 200) {
        // 🔥 Remover de la base de datos local
        final deleted = await _storage.deleteScheduledNotificationByAppointment(appointmentId);

        if (deleted) {
          print('Notificación cancelada exitosamente: $notificationId');
          return true;
        } else {
          print('Notificación cancelada en OneSignal pero no se pudo eliminar de la DB local');
          return true; // Aún consideramos exitoso porque se canceló en OneSignal
        }
      } else {
        print('Error al cancelar notificación: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al cancelar notificación: $e');
      return false;
    }
  }

  /// Cancela todas las notificaciones programadas del usuario actual
  static Future<void> cancelAllScheduledNotifications() async {
    try {
      // 🔥 Obtener usuario actual
      final currentUser = await _storage.getCurrentUser();
      if (currentUser == null) {
        print('No hay usuario activo');
        return;
      }

      // 🔥 Obtener todas las notificaciones del usuario actual
      final notifications = await _storage.getScheduledNotificationsByUser(currentUser.id);

      // Cancelar cada notificación en OneSignal
      for (final notification in notifications) {
        final notificationId = notification['notification_id'] as String;

        try {
          await http.delete(
            Uri.parse('https://onesignal.com/api/v1/notifications/$notificationId?app_id=$_oneSignalAppId'),
            headers: {
              'Authorization': 'Basic $_oneSignalApiKey',
            },
          );
          print('Notificación cancelada: $notificationId');
        } catch (e) {
          print('Error al cancelar notificación $notificationId: $e');
        }
      }

      // 🔥 Limpiar todas las notificaciones del usuario de la base de datos
      await _storage.deleteAllScheduledNotificationsByUser(currentUser.id);

      print('Todas las notificaciones del usuario ${currentUser.id} han sido canceladas');

    } catch (e) {
      print('Error al cancelar todas las notificaciones: $e');
    }
  }

  /// Obtiene las notificaciones programadas del usuario actual
  static Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    try {
      // 🔥 Obtener usuario actual
      final currentUser = await _storage.getCurrentUser();
      if (currentUser == null) {
        print('No hay usuario activo');
        return [];
      }

      // 🔥 Obtener notificaciones del usuario actual
      return await _storage.getScheduledNotificationsByUser(currentUser.id);
    } catch (e) {
      print('Error al obtener notificaciones programadas: $e');
      return [];
    }
  }

  // === MÉTODOS AUXILIARES (sin cambios) ===
  static DateTime _buildAppointmentDateTimeInPeru(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      int.parse(timeParts[2]),
    );
  }

  static DateTime _calculateNotificationDateTime(DateTime appointmentDateTime, String reminderType) {
    switch (reminderType) {
      case '30 minutos antes':
        return appointmentDateTime.subtract(const Duration(minutes: 30));
      case '1 hora antes':
        return appointmentDateTime.subtract(const Duration(hours: 1));
      case '1 día antes':
        return appointmentDateTime.subtract(const Duration(days: 1));
      default:
        return appointmentDateTime.subtract(const Duration(minutes: 30));
    }
  }

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

  /// Envía una notificación inmediata
  static Future<void> sendImmediateNotification({
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String? playerId = OneSignal.User.pushSubscription.id;
      if (playerId == null) return;

      Map<String, dynamic> payload = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [playerId],
        'headings': {'en': title, 'es': title},
        'contents': {'en': message, 'es': message},
      };

      if (additionalData != null) {
        payload['data'] = additionalData;
      }

      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: jsonEncode(payload),
      );
    } catch (e) {
      print('Error al enviar notificación: $e');
    }
  }
}
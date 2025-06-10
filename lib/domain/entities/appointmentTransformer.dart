import 'package:flutter/material.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/pet.dart';
import '../../data/repositories/local_storage_service.dart';

class AppointmentTransformer {
  // Instancia del servicio de almacenamiento local
  static final LocalStorageService _localStorageService = LocalStorageService();

  // Transformar Appointment a formato UI (ahora asíncrono)
  static Future<Map<String, dynamic>> appointmentToUIFormat(
      Appointment appointment
      ) async {
    // Buscar la mascota correspondiente usando LocalStorageService
    Pet? pet;
    try {
      pet = await _localStorageService.getPetById(appointment.petId);
    } catch (e) {
      // Si no se encuentra la mascota, usar valores por defecto
      pet = null;
    }

    // Si no se encuentra la mascota, usar mascota por defecto
    final petName = pet?.name ?? 'Desconocida';

    // Parsear la fecha (formato: 2025-06-10)
    final dateParts = appointment.date.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    // Convertir hora de 24h a 12h (formato: 17:45:00 -> 5:45 PM)
    final formattedTime = _formatTimeTo12Hour(appointment.time);

    // Obtener icono y color basado en el tipo
    final iconAndColor = _getIconAndColorForType(appointment.type);

    return {
      'id': appointment.id,
      'title': appointment.name,
      'time': formattedTime,
      'clinic': 'Clínica Veterinaria San Miguel', // valor por defecto
      'date': {
        'day': day,
        'month': month,
        'year': year,
      },
      'icon': iconAndColor['icon'],
      'color': iconAndColor['color'],
      'petName': petName,
      'note': appointment.note,
      'type': appointment.type,
    };
  }

  // Convertir lista de Appointments a formato UI (ahora asíncrono)
  static Future<List<Map<String, dynamic>>> appointmentsToUIFormat(
      List<Appointment> appointments
      ) async {
    List<Map<String, dynamic>> result = [];

    for (Appointment appointment in appointments) {
      final uiFormat = await appointmentToUIFormat(appointment);
      result.add(uiFormat);
    }

    return result;
  }

  // Convertir hora de 24h a 12h
  static String _formatTimeTo12Hour(String time24h) {
    final parts = time24h.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];

    String period = 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour == 12) {
      period = 'PM';
    } else if (hour > 12) {
      hour -= 12;
      period = 'PM';
    }

    return '$hour:$minute $period';
  }

  // Obtener icono y color basado en el tipo de cita
  static Map<String, String> _getIconAndColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'vacuna':
        return {
          'icon': 'vaccines',
          'color': '#8158B7',
        };
      case 'baño':
        return {
          'icon': 'bathtub',
          'color': '#35B4DD',
        };
      case 'medicina':
        return {
          'icon': 'medical_services',
          'color': '#FF6B6B',
        };
      case 'otro':
        return {
          'icon': 'pets',
          'color': '#4ECDC4',
        };
      default:
        return {
          'icon': 'event',
          'color': '#95A5A6',
        };
    }
  }
}
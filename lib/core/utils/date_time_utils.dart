// lib/utils/date_time_utils.dart

class DateTimeUtils {
  // Constructor privado para prevenir instanciación
  DateTimeUtils._();

  /// Formatea una fecha string a un formato amigable
  ///
  /// Ejemplos:
  /// - "2025-06-11" -> "Hoy", "Mañana", "Viernes 13"
  ///
  /// [dateString] puede estar en formato:
  /// - yyyy-MM-dd (2025-06-11) - Formato principal
  /// - dd-MM-yy (25-06-11)
  /// - dd-MM-yyyy (25-06-2024)
  static String formatDate(String dateString) {
    try {
      DateTime appointmentDate = _parseDate(dateString);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDateOnly = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day
      );

      // Calcular la diferencia de días
      final difference = appointmentDateOnly.difference(today).inDays;

      if (difference == 0) {
        return 'Hoy';
      } else if (difference == 1) {
        return 'Mañana';
      } else if (difference == -1) {
        return 'Ayer';
      } else {
        // Para fechas más lejanas o pasadas, mostrar día de la semana y número
        final dayName = _getDayName(appointmentDate.weekday);
        return '$dayName ${appointmentDate.day}';
      }
    } catch (e) {
      // En caso de error, devolver la fecha original
      return dateString;
    }
  }

  /// Formatea una hora string de 24h a formato 12h con AM/PM
  ///
  /// Ejemplos:
  /// - "19:25:00" -> "7:25 PM"
  /// - "09:30:00" -> "9:30 AM"
  /// - "00:15:00" -> "12:15 AM"
  static String formatTime(String timeString) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        // Convertir a formato 12 horas
        String period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

        // Formatear minutos con cero a la izquierda si es necesario
        String formattedMinute = minute.toString().padLeft(2, '0');

        return '$displayHour:$formattedMinute $period';
      }

      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  /// Formatea fecha y hora juntas
  ///
  /// Ejemplo:
  /// - formatDateTime("25-06-11", "19:25:00") -> "Hoy · 7:25 PM"
  static String formatDateTime(String dateString, String timeString) {
    final formattedDate = formatDate(dateString);
    final formattedTime = formatTime(timeString);
    return '$formattedDate · $formattedTime';
  }

  /// Convierte un string de fecha a DateTime
  /// Maneja múltiples formatos comunes
  static DateTime _parseDate(String dateString) {
    try {
      // Formato yyyy-MM-dd (como 2025-06-11) - Prioridad alta ya que es tu formato
      if (dateString.contains('-') && dateString.length >= 8) {
        final parts = dateString.split('-');
        if (parts.length == 3 && parts[0].length == 4) {
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);

          return DateTime(year, month, day);
        }
      }

      // Formato dd-MM-yy o dd-MM-yyyy (como 25-06-11 o 25-06-2025)
      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        if (parts.length == 3 && parts[0].length <= 2) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);

          // Si el año es de 2 dígitos, asumir 20xx
          if (year < 100) {
            year += 2000;
          }

          return DateTime(year, month, day);
        }
      }

      // Intentar parsear con DateTime.parse como último recurso
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parseando fecha: $dateString - $e');
      throw e;
    }
  }

  /// Obtiene el nombre del día de la semana en español
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  /// Obtiene el nombre del mes en español
  static String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  /// Verifica si una fecha es hoy
  static bool isToday(String dateString) {
    try {
      final date = _parseDate(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);

      return dateOnly.isAtSameMomentAs(today);
    } catch (e) {
      return false;
    }
  }

  /// Verifica si una fecha es mañana
  static bool isTomorrow(String dateString) {
    try {
      final date = _parseDate(dateString);
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      return dateOnly.isAtSameMomentAs(tomorrow);
    } catch (e) {
      return false;
    }
  }

  /// Calcula los días entre dos fechas
  static int daysBetween(String startDate, String endDate) {
    try {
      final start = _parseDate(startDate);
      final end = _parseDate(endDate);

      final startDateOnly = DateTime(start.year, start.month, start.day);
      final endDateOnly = DateTime(end.year, end.month, end.day);

      return endDateOnly.difference(startDateOnly).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Formatea una fecha completa con formato largo
  /// Ejemplo: "Lunes 25 de Junio de 2024"
  static String formatFullDate(String dateString) {
    try {
      final date = _parseDate(dateString);
      final dayName = _getDayName(date.weekday);
      final monthName = getMonthName(date.month);

      return '$dayName ${date.day} de $monthName de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
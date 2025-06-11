import 'package:intl/intl.dart';
import '../../domain/entities/appointment.dart';

class AppointmentFilter {
  static List<Appointment> filterByDateRange({
    required List<Appointment> appointments,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    // Cambiado para incluir segundos
    final timeFormat = DateFormat('HH:mm:ss');

    final filteredAppointments = appointments.where((appointment) {
      try {
        // Parsear fecha y hora
        final datePart = dateFormat.parseStrict(appointment.date);
        final timePart = timeFormat.parseStrict(appointment.time);

        // Combinar fecha y hora
        final fullDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          timePart.hour,
          timePart.minute,
          timePart.second,
        );

        // Comparación corregida: usar isAfter/isBefore sin isAtSameMomentAs
        return fullDateTime.isAfter(startDateTime) &&
            fullDateTime.isBefore(endDateTime);
      } catch (e) {
        // Debug: imprimir errores para identificar problemas
        print('Error parsing appointment ${appointment.id}: ${appointment.date} ${appointment.time} - $e');
        return false;
      }
    }).toList();

    // Ordenar por fecha y hora (de más antigua a más futura)
    filteredAppointments.sort((a, b) {
      try {
        final dateFormatSort = DateFormat('yyyy-MM-dd');
        final timeFormatSort = DateFormat('HH:mm:ss');

        // Parsear fecha y hora para appointment a
        final datePartA = dateFormatSort.parseStrict(a.date);
        final timePartA = timeFormatSort.parseStrict(a.time);
        final fullDateTimeA = DateTime(
          datePartA.year,
          datePartA.month,
          datePartA.day,
          timePartA.hour,
          timePartA.minute,
          timePartA.second,
        );

        // Parsear fecha y hora para appointment b
        final datePartB = dateFormatSort.parseStrict(b.date);
        final timePartB = timeFormatSort.parseStrict(b.time);
        final fullDateTimeB = DateTime(
          datePartB.year,
          datePartB.month,
          datePartB.day,
          timePartB.hour,
          timePartB.minute,
          timePartB.second,
        );

        return fullDateTimeA.compareTo(fullDateTimeB);
      } catch (e) {
        print('Error sorting appointments: $e');
        return 0;
      }
    });

    return filteredAppointments;
  }

  // Método adicional para filtrar solo citas futuras (más común)
  static List<Appointment> filterFutureAppointments({
    required List<Appointment> appointments,
    DateTime? fromDate,
  }) {
    final startDate = fromDate ?? DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    final futureAppointments = appointments.where((appointment) {
      try {
        final datePart = dateFormat.parseStrict(appointment.date);
        final timePart = timeFormat.parseStrict(appointment.time);

        final fullDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          timePart.hour,
          timePart.minute,
          timePart.second,
        );

        // Solo citas futuras
        return fullDateTime.isAfter(startDate);
      } catch (e) {
        print('Error parsing appointment ${appointment.id}: ${appointment.date} ${appointment.time} - $e');
        return false;
      }
    }).toList();

    // Ordenar por fecha y hora (de más antigua a más futura)
    futureAppointments.sort((a, b) {
      try {
        final dateFormatSort = DateFormat('yyyy-MM-dd');
        final timeFormatSort = DateFormat('HH:mm:ss');

        // Parsear fecha y hora para appointment a
        final datePartA = dateFormatSort.parseStrict(a.date);
        final timePartA = timeFormatSort.parseStrict(a.time);
        final fullDateTimeA = DateTime(
          datePartA.year,
          datePartA.month,
          datePartA.day,
          timePartA.hour,
          timePartA.minute,
          timePartA.second,
        );

        // Parsear fecha y hora para appointment b
        final datePartB = dateFormatSort.parseStrict(b.date);
        final timePartB = timeFormatSort.parseStrict(b.time);
        final fullDateTimeB = DateTime(
          datePartB.year,
          datePartB.month,
          datePartB.day,
          timePartB.hour,
          timePartB.minute,
          timePartB.second,
        );

        return fullDateTimeA.compareTo(fullDateTimeB);
      } catch (e) {
        print('Error sorting appointments: $e');
        return 0;
      }
    });

    return futureAppointments;
  }

  // Método para filtrar por mes específico
  static List<Appointment> filterByMonth({
    required List<Appointment> appointments,
    required int year,
    required int month,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final monthlyAppointments = appointments.where((appointment) {
      try {
        final datePart = dateFormat.parseStrict(appointment.date);
        return datePart.year == year && datePart.month == month;
      } catch (e) {
        print('Error parsing appointment date ${appointment.id}: ${appointment.date} - $e');
        return false;
      }
    }).toList();

    // Ordenar por fecha y hora (de más antigua a más futura)
    monthlyAppointments.sort((a, b) {
      try {
        final dateFormatSort = DateFormat('yyyy-MM-dd');
        final timeFormatSort = DateFormat('HH:mm:ss');

        // Parsear fecha y hora para appointment a
        final datePartA = dateFormatSort.parseStrict(a.date);
        final timePartA = timeFormatSort.parseStrict(a.time);
        final fullDateTimeA = DateTime(
          datePartA.year,
          datePartA.month,
          datePartA.day,
          timePartA.hour,
          timePartA.minute,
          timePartA.second,
        );

        // Parsear fecha y hora para appointment b
        final datePartB = dateFormatSort.parseStrict(b.date);
        final timePartB = timeFormatSort.parseStrict(b.time);
        final fullDateTimeB = DateTime(
          datePartB.year,
          datePartB.month,
          datePartB.day,
          timePartB.hour,
          timePartB.minute,
          timePartB.second,
        );

        return fullDateTimeA.compareTo(fullDateTimeB);
      } catch (e) {
        print('Error sorting appointments: $e');
        return 0;
      }
    });

    return monthlyAppointments;
  }
}
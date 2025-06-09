import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<bool> addAppointment(Appointment appointment);
  Future<List<Appointment>?> getUserAppointments({int? petId});
}

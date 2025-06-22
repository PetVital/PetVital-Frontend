import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Appointment?> addAppointment(Appointment appointment);
  Future<List<Appointment>?> getUserAppointments();
  Future<List<Appointment>?> getPetAppointments(int petId);
  Future<Appointment?> getAppointmentDetail(int appointmentId);
  Future<bool> deleteAppointment(int appointmentId);
}

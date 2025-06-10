import '../../domain/repositories/appointment_repository.dart';
import '../../domain/entities/appointment.dart';
import '../api/appointment_api.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentApi appointmentApi;

  AppointmentRepositoryImpl(this.appointmentApi);

  @override
  Future<bool> addAppointment(Appointment appointment) async {
    return await appointmentApi.addAppointment(appointment);
  }

  @override
  Future<List<Appointment>?> getUserAppointments() async {
    return await appointmentApi.getUserAppointments(); // ← Llamada nombrada
  }

}
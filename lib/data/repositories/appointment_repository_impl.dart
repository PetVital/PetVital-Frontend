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

  @override
  Future<List<Appointment>?> getPetAppointments(int petId) async {
    return await appointmentApi.getPetAppointments(petId); // ← Llamada nombrada
  }

  @override
  Future<Appointment?> getAppointmentDetail(int appointmentId) async {
    return await appointmentApi.getAppointmentDetail(appointmentId); // ← Llamada nombrada
  }

  @override
  Future<bool> deleteAppointment(int appointmentId) async {
    return await appointmentApi.deleteAppointment(appointmentId);
  }

}
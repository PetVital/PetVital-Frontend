import '../domain/entities/appointment.dart';
import '../domain/repositories/appointment_repository.dart';

class AddAppointmentUseCase {
  final AppointmentRepository appointmentRepository;

  AddAppointmentUseCase(this.appointmentRepository);

  Future<Appointment?> addAppointment(Appointment appointment) async {
    try {
      final Appointment? appointmentResponse = await appointmentRepository.addAppointment(appointment);
      return appointmentResponse;
    } catch (e) {
      return null;
    }
  }
}

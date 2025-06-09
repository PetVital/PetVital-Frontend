import '../domain/entities/appointment.dart';
import '../domain/repositories/appointment_repository.dart';

class AddAppointmentUseCase {
  final AppointmentRepository appointmentRepository;

  AddAppointmentUseCase(this.appointmentRepository);

  Future<bool> addAppointment(Appointment appointment) async {
    try {
      final bool response = await appointmentRepository.addAppointment(appointment);
      return response;
    } catch (e) {
      return false;
    }
  }
}

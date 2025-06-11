import '../domain/repositories/appointment_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentRepository appointmentRepository;

  DeleteAppointmentUseCase(this.appointmentRepository);

  Future<bool> deleteAppointment(int appointmentId) async {
    try {
      final bool deleteResponse = await appointmentRepository.deleteAppointment(appointmentId);
      return deleteResponse;
    } catch (e) {
      return false;
    }
  }
}
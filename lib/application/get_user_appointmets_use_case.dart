import '../domain/entities/appointment.dart';
import '../domain/repositories/appointment_repository.dart';

class GetUserAppointmentsUseCase {
  final AppointmentRepository _repository;

  GetUserAppointmentsUseCase(this._repository);

  Future<List<Appointment>?> getUserAppointments() async {
    try {
      return await _repository.getUserAppointments();
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }
}
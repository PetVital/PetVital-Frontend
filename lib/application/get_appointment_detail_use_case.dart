import '../domain/entities/appointment.dart';
import '../domain/repositories/appointment_repository.dart';

class GetAppointmentDetailUseCase {
  final AppointmentRepository _repository;

  GetAppointmentDetailUseCase(this._repository);

  Future<Appointment?> getAppointmentDetail(int appointmentId) async {
    try {
      return await _repository.getAppointmentDetail(appointmentId);
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }
}
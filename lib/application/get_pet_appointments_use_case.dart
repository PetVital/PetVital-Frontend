import '../domain/entities/appointment.dart';
import '../domain/repositories/appointment_repository.dart';

class GetPetAppointmentsUseCase {
  final AppointmentRepository _repository;

  GetPetAppointmentsUseCase(this._repository);

  Future<List<Appointment>?> getPetAppointments(int petId) async {
    try {
      return await _repository.getPetAppointments(petId);
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }
}
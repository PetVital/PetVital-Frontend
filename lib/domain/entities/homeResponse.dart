import 'pet.dart';
import 'appointment.dart';

class HomeResponse {
  final List<Pet> pets;
  final List<Appointment> appointments;

  HomeResponse({
    required this.pets,
    required this.appointments,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      pets: (json['mascotas'] as List<dynamic>)
          .map((e) => Pet.fromJson(e as Map<String, dynamic>))
          .toList(),
      appointments: (json['citas'] as List<dynamic>)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Appointment {
  final int id;
  final String type;        // tipo_recordatorio
  final String name;        // nombre
  final String date;        // fecha
  final String time;        // hora
  final String note;        // nota
  final String reminder;    // recordatorio
  final int petId;          // mascota.id

  Appointment({
    required this.id,
    required this.type,
    required this.name,
    required this.date,
    required this.time,
    required this.note,
    required this.reminder,
    required this.petId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      type: json['tipo_recordatorio'],
      name: json['nombre'],
      date: json['fecha'],
      time: json['hora'],
      note: json['nota'],
      reminder: json['recordatorio'],
      petId: json['mascota']['mascota_id'], // ← importante si el campo es 'mascota_id' en mascota
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_recordatorio': type,
      'nombre': name,
      'fecha': date,
      'hora': time,
      'nota': note,
      'recordatorio': reminder,
      'mascota': petId,
    };
  }
}

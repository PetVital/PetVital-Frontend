class Checkup {
  final int id;
  final String title;
  final String description;
  final String date;
  final int petId;

  Checkup({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.petId,
  });

  factory Checkup.fromJson(Map<String, dynamic> json) {
    return Checkup(
      id: json['id'],
      title: json['titulo'],
      description: json['descripcion'],
      date: json['fecha'],
      petId: json['mascota']['mascota_id'], // ← importante si el campo es 'mascota_id' en mascota
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': title,
      'descripcion': description,
      'fecha': date,
      'mascota': petId,
    };
  }
}

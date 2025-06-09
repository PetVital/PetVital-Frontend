class Pet {
  final int id;
  final String name;
  final String type;
  final String breed;
  final String gender;
  final int age;
  final String timeUnit;
  final double weight;
  final int userId;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.age,
    required this.timeUnit,
    required this.weight,
    required this.userId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['mascota_id'],
    name: json['nombres'],
    type: json['tipo'],
    breed: json['raza'],
    gender: json['genero'],
    age: json['edad'],
    timeUnit: json['unidad_tiempo'],
    weight: (json['peso'] as num).toDouble(),
    userId: json['usuario']['user_id'],
  );

  Map<String, dynamic> toJson() => {
    'mascota_id': id,
    'nombres': name,
    'tipo': type,
    'raza': breed,
    'genero': gender,
    'edad': age,
    'unidad_tiempo': timeUnit,
    'peso': weight,
    'usuario': userId,
  };

  // Para convertir desde la base de datos
  factory Pet.fromDb(Map<String, dynamic> json) => Pet(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    breed: json['breed'],
    gender: json['gender'],
    age: json['age'],
    timeUnit: json['timeUnit'],
    weight: (json['weight'] as num).toDouble(),
    userId: json['userId'],
  );

// Para guardar en la base de datos
  Map<String, dynamic> toDbJson() => {
    'id': id,
    'name': name,
    'type': type,
    'breed': breed,
    'gender': gender,
    'age': age,
    'timeUnit': timeUnit,
    'weight': weight,
    'userId': userId,
  };

}

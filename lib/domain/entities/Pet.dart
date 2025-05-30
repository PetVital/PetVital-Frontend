class Pet {
  final int id;
  final String name;
  final String type;
  final String breed;
  final String gender;
  final int age;
  final String timeUnit;
  final double weight;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.age,
    required this.timeUnit,
    required this.weight,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'],
    name: json['nombre'],
    type: json['tipo'],
    breed: json['raza'],
    gender: json['sexo'],
    age: json['edad'],
    timeUnit: json['unidadTiempo'],
    weight: (json['peso'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': name,
    'tipo': type,
    'raza': breed,
    'sexo': gender,
    'edad': age,
    'unidadTiempo': timeUnit,
    'peso': weight,
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
  };

}

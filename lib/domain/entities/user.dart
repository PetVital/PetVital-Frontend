class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  // Método para crear una instancia de User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'].toString(), // Convertir a String
      firstName: json['nombres'], // Mapea 'nombres' a 'firstName'
      lastName: json['apellidos'], // Mapea 'apellidos' a 'lastName'
      email: json['email'], // Mapea 'email' a 'email'
    );
  }

  // Método para convertir una instancia de User a un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': firstName,
      'apellidos': lastName,
      'email': email,
    };
  }
}
class Message {
  final int id;
  final String message;
  final bool isBot;
  final String timestamp;

  Message({
    required this.id,
    required this.message,
    required this.isBot,
    required this.timestamp,
  });

  // Para convertir desde un JSON (ej. respuesta de una API)
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    message: json['mensaje'],
    isBot: json['esBot'],
    timestamp: json['fechaHora'],
  );

  // Para convertir a JSON (ej. enviar a una API)
  Map<String, dynamic> toJson() => {
    'id': id,
    'mensaje': message,
    'esBot': isBot,
    'fechaHora': timestamp,
  };

  // Para convertir desde la base de datos
  factory Message.fromDb(Map<String, dynamic> json) => Message(
    id: json['id'],
    message: json['message'],
    isBot: json['isBot'] == 1,
    timestamp: json['timestamp'],
  );

  // Para guardar en la base de datos
  Map<String, dynamic> toDbJson() => {
    'id': id,
    'message': message,
    'isBot': isBot ? 1 : 0, // SQLite no tiene booleanos
    'timestamp': timestamp,
  };
}

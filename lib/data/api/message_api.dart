import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/message.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';
import '../../domain/entities/pet.dart';

class MessageApi {
  final String baseUrl = ApiConstants.baseUrl;
  final localStorageService = LocalStorageService();

  Future<Message?> sendMessage(Message message) async {
    // Obtener mensajes previos
    final List<Message> previousMessages = await localStorageService.getAllMessages();
    // Obtener mascotas (memoryBank)
    final List<Pet> pets = await localStorageService.getAllPets();

    // Construir body para el request
    final body = {
      'currentMessage': message.message,
      'previousMessages': previousMessages.map((msg) => {
        'message': msg.message,
        'isBot': msg.isBot,
        'timestamp': msg.timestamp,
      }).toList(),
      'memoryBank': pets.map((pet) => {
        'name': pet.name,
        'type': pet.type,
        'breed': pet.breed,
        'gender': pet.gender,
        'age': '${pet.age} ${pet.timeUnit}',
        'weight': '${pet.weight} kg',
      }).toList(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/content/generate/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String botMessage = responseData['botMessage'];

      // Construir el mensaje de respuesta
      final responseMessage = Message(
        id: message.id+1,
        message: botMessage,
        isBot: true,
        timestamp: DateTime.now().toIso8601String(),
      );

      return responseMessage;
    } else {
      print('Error al enviar el mensaje: ${response.body}');
      return null;
    }
  }
}


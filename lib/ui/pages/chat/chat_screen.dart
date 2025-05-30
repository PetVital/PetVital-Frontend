import 'package:flutter/material.dart';
import '../../../data/repositories/local_storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final localStorageService = LocalStorageService();
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialMessage();
  }

  Future<void> _loadInitialMessage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pets = await localStorageService.getAllPets();
      final initialMessage = await _generateWelcomeMessage(pets);

      setState(() {
        messages = [initialMessage];
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      // En caso de error, usar mensaje por defecto
      final defaultMessage = {
        "id": 1,
        "message": "¡Hola! Soy el asistente virtual de PetVital. ¿En qué puedo ayudarte hoy con el cuidado de tu mascota?",
        "isBot": true,
        "timestamp": DateTime.now().toIso8601String()
      };

      setState(() {
        messages = [defaultMessage];
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  Future<Map<String, dynamic>> _generateWelcomeMessage(List<dynamic> pets) async {
    String message;

    if (pets.isEmpty) {
      message = "¡Hola! Soy el asistente virtual de PetVital. ¿En qué puedo ayudarte hoy con el cuidado de tu mascota?";
    } else {
      final petCount = pets.length;

      if (petCount == 1) {
        final petName = pets[0].name;
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes una mascota llamada $petName. ¿Te gustaria hablar sobre alguna de ellas?";
      } else if (petCount == 2) {
        final pet1Name = pets[0].name;
        final pet2Name = pets[1].name;
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes 2 mascotas: $pet1Name y $pet2Name. ¿Te gustaria hablar sobre alguna de ellas?";
      } else if (petCount <= 4) {
        final petNames = pets.map((pet) => pet.name).join(', ');
        final lastCommaIndex = petNames.lastIndexOf(',');
        final formattedNames = lastCommaIndex != -1
            ? petNames.substring(0, lastCommaIndex) + ' y' + petNames.substring(lastCommaIndex + 1)
            : petNames;
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes $petCount mascotas: $formattedNames. ¿Te gustaria hablar sobre alguna de ellas?";
      } else {
        // Para más de 4 mascotas, solo mencionar la cantidad
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes $petCount mascotas. ¡Qué maravilloso! ¿Te gustaria hablar sobre alguna de ellas?";
      }
    }

    return {
      "id": 1,
      "message": "$message", // Agrega la hora al mensaje
      "isBot": true,
      "timestamp": DateTime.now().toIso8601String(),
    };

  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      "id": messages.length + 1,
      "message": _messageController.text.trim(),
      "isBot": false,
      "timestamp": DateTime.now().toIso8601String(),
      "avatar": "user"
    };

    setState(() {
      messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simular respuesta del bot después de un delay
    _simulateBotResponse();
  }

  void _simulateBotResponse() {
    Future.delayed(const Duration(seconds: 2), () {
      final botResponses = [
        "Entiendo tu preocupación. ¿Podrías decirme qué edad tiene tu mascota y si ha tenido cambios en su rutina recientemente?",
        "Es importante observar el comportamiento de tu mascota. ¿Ha bebido agua normalmente?",
        "Te recomiendo consultar con un veterinario si el problema persiste más de 24 horas.",
        "¿Tu mascota muestra algún signo de malestar como vómitos o letargo?",
        "Puedo ayudarte a encontrar una clínica veterinaria cerca de ti si necesitas atención urgente."
      ];

      final randomResponse = botResponses[
      DateTime.now().millisecond % botResponses.length
      ];

      final botMessage = {
        "id": messages.length + 1,
        "message": randomResponse,
        "isBot": true,
        "timestamp": DateTime.now().toIso8601String()
      };

      setState(() {
        messages.add(botMessage);
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading ? _buildLoadingIndicator() : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8158B7)),
          ),
          SizedBox(height: 16),
          Text(
            'Preparando tu asistente...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          const SizedBox(width: 5),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PetVital Asistente',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'En línea',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isBot = message['isBot'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isBot
                    ? const LinearGradient(
                  colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isBot ? null : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(20),
                  bottomRight: isBot ? const Radius.circular(20) : const Radius.circular(4),
                ),
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                  color: isBot ? Colors.white : const Color(0xFF2C3E50),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
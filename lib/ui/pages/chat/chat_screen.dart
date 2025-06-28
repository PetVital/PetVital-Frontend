import 'package:flutter/material.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/pet.dart';
import '../../../main.dart';
import '../../../application/send_message_use_case.dart';

class ChatScreen extends StatefulWidget {
  final Pet? pet;

  const ChatScreen({Key? key, this.pet}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final localStorageService = LocalStorageService();
  List<Message> messages = [];
  bool _isLoading = true;
  bool _isbotTyping = false;
  int _messageIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Intentar cargar mensajes existentes de la BD
      final existingMessages = await localStorageService.getAllMessages();

      if (existingMessages.isNotEmpty) {
        // Si hay mensajes existentes, mostrarlos
        setState(() {
          messages = existingMessages;
          _messageIdCounter = existingMessages.length + 1;
          _isLoading = false;
        });
      } else {
        // Si no hay mensajes, generar mensaje de bienvenida
        await _generateAndStoreWelcomeMessage();
      }

      if(widget.pet!=null){
        setState(() {
          _messageController.text="Quiero hablar de mi mascota ${widget.pet?.name}";
        });
        _sendMessage();
      }

      _scrollToBottom();
    } catch (e) {
      print('Error al cargar mensajes: $e');
      // En caso de error, generar mensaje de bienvenida por defecto
      await _generateAndStoreWelcomeMessage();
    }
  }

  Future<void> _generateAndStoreWelcomeMessage() async {
    try {
      final pets = await localStorageService.getAllPets();
      final welcomeMessage = await _generateWelcomeMessage(pets);

      // Guardar el mensaje de bienvenida en la BD
      await _storeMessage(welcomeMessage);

      setState(() {
        messages = [welcomeMessage];
        _messageIdCounter = 2;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al generar mensaje de bienvenida: $e');
      // Crear mensaje por defecto si falla todo
      final defaultMessage = Message(
        id: 1,
        message: "¡Hola! Soy el asistente virtual de PetVital. ¿En qué puedo ayudarte hoy con el cuidado de tu mascota?",
        isBot: true,
        timestamp: DateTime.now().toIso8601String(),
      );

      await _storeMessage(defaultMessage);

      setState(() {
        messages = [defaultMessage];
        _messageIdCounter = 2;
        _isLoading = false;
      });
    }
  }

  Future<Message> _generateWelcomeMessage(List<dynamic> pets) async {
    String message;

    if (pets.isEmpty) {
      message = "¡Hola! Soy el asistente virtual de PetVital. ¿En qué puedo ayudarte hoy con el cuidado de tu mascota?";
    } else {
      final petCount = pets.length;

      if (petCount == 1) {
        final petName = pets[0].name;
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes una mascota llamada $petName. ¿Te gustaría hablar sobre ella?";
      } else if (petCount == 2) {
        final pet1Name = pets[0].name;
        final pet2Name = pets[1].name;
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes 2 mascotas: $pet1Name y $pet2Name. ¿Te gustaría hablar sobre alguna de ellas?";
      } else if (petCount <= 4) {
        final petNames = pets.map((pet) => pet.name).join(', ');
        final lastCommaIndex = petNames.lastIndexOf(',');
        final formattedNames = lastCommaIndex != -1
            ? petNames.substring(0, lastCommaIndex) + ' y' + petNames.substring(lastCommaIndex + 1)
            : petNames;
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes $petCount mascotas: $formattedNames. ¿Te gustaría hablar sobre alguna de ellas?";
      } else {
        // Para más de 4 mascotas, solo mencionar la cantidad
        message = "¡Hola! Soy el asistente virtual de PetVital. Veo que tienes $petCount mascotas. ¡Qué maravilloso! ¿Te gustaría hablar sobre alguna de ellas?";
      }
    }

    return Message(
      id: 1,
      message: message,
      isBot: true,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _storeMessage(Message message) async {
    try {
      await localStorageService.insertMessage(message);
    } catch (e) {
      print('Error al guardar mensaje: $e');
    }
  }

  void _sendMessage() async{
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: _messageIdCounter+=2,
      message: _messageController.text.trim(),
      isBot: false,
      timestamp: DateTime.now().toIso8601String(),
    );

    _storeMessage(newMessage);
    setState(() {
      messages.add(newMessage);
    });

    _messageController.clear();

    try {
      setState(() {
        _isbotTyping = true;
      });

      // Hacer scroll para mostrar el indicador de escritura
      _scrollToBottom();

      final sendMessageUseCase = getIt<SendMessageUseCase>();
      final messageResponse = await sendMessageUseCase.sendMessage(newMessage);

      setState(() {
        _isbotTyping = false;
      });

      if (messageResponse != null) {
        _storeMessage(messageResponse);
        setState(() {
          messages.add(messageResponse);
        });
      } else {
        _showError('No se pudo registrar la mascota. Intenta nuevamente.');
      }
      _scrollToBottom();

    } catch (e) {
      setState(() {
        _isbotTyping = false;
      });
      _showError('Error al guardar la mascota: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      itemCount: messages.length + (_isbotTyping ? 1 : 0), // Agregar 1 si el bot está escribiendo
      itemBuilder: (context, index) {
        // Si es el último item y el bot está escribiendo, mostrar indicador
        if (index == messages.length && _isbotTyping) {
          return _buildTypingIndicator();
        }

        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const TypingAnimation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isBot = message.isBot;

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
                message.message,
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

// Widget personalizado para la animación de los tres puntitos
class TypingAnimation extends StatefulWidget {
  const TypingAnimation({Key? key}) : super(key: key);

  @override
  State<TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final opacity = (_fadeAnimation.value + delay).clamp(0.3, 1.0);

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
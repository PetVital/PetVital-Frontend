// lib/ui/pages/chat/chat_screen.dart
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/seed/${100 + index}/200',
                  ),
                ),
                title: Text(
                  'Dr. ${["García", "Martínez", "López", "Rodríguez", "Pérez"][index % 5]}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Último mensaje: ${["¿Cómo está tu mascota?", "Recuerda la cita de mañana", "Envíame una foto del tratamiento", "Te confirmo la reserva", "Necesitamos revisar las vacunas"][index % 5]}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${DateTime.now().hour - (index % 5)}:${DateTime.now().minute}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (index % 3 == 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {},
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {},
      ),
    );
  }
}
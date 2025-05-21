// lib/ui/pages/appointments/appointments_screen.dart
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: CircleAvatar(
                backgroundColor: index % 2 == 0
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.purple.withOpacity(0.2),
                child: Icon(
                  index % 2 == 0 ? Icons.calendar_today : Icons.medical_services,
                  color: index % 2 == 0 ? Colors.blue : Colors.purple,
                ),
              ),
              title: Text(
                index % 2 == 0 ? 'Consulta veterinaria' : 'Vacunación anual',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: ${DateTime.now().add(Duration(days: index + 1)).day}/${DateTime.now().add(Duration(days: index + 1)).month}/2025',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hora: ${10 + index}:00 ${index > 2 ? "PM" : "AM"}',
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
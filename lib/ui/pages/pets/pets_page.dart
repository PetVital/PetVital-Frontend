// lib/ui/pages/pets/pets_page.dart
import 'package:flutter/material.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          final petNames = ['Max', 'Luna', 'Rocky', 'Bella', 'Coco', 'Toby'];
          final petTypes = ['Perro', 'Gato', 'Perro', 'Gato', 'Ave', 'Perro'];
          final petColors = [
            Colors.amber,
            Colors.blue,
            Colors.purple,
            Colors.teal,
            Colors.orange,
            Colors.pink,
          ];

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    color: petColors[index].withOpacity(0.3),
                    child: Center(
                      child: Icon(
                        petTypes[index] == 'Perro'
                            ? Icons.pets
                            : petTypes[index] == 'Gato'
                            ? Icons.coronavirus
                            : Icons.flutter_dash,
                        size: 50,
                        color: petColors[index],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          petNames[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          petTypes[index],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
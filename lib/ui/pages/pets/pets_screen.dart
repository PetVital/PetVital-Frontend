// lib/ui/pages/pets/pets_screen.dart
import 'package:flutter/material.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({Key? key}) : super(key: key);

  // Datos simulados de mascotas
  final List<Map<String, dynamic>> pets = const [
    {
      'name': 'Rocky',
      'breed': 'Labrador Retriever',
      'gender': 'Macho',
      'age': 3,
      'weight': '28 kg',
      'birthDate': '15/05/2020',
      'microchip': true,
      'microchipNumber': '#12345678',
      'sterilized': true,
      'color': Colors.purple,
      'icon': Icons.pets,
    },
    {
      'name': 'Luna',
      'breed': 'Gato Siamés',
      'gender': 'Hembra',
      'age': 2,
      'weight': '4.5 kg',
      'birthDate': '20/08/2021',
      'microchip': true,
      'microchipNumber': '#87654321',
      'sterilized': true,
      'color': Colors.blue,
      'icon': Icons.pets,
    },
    {
      'name': 'Max',
      'breed': 'Golden Retriever',
      'gender': 'Macho',
      'age': 5,
      'weight': '32 kg',
      'birthDate': '10/03/2018',
      'microchip': false,
      'microchipNumber': '',
      'sterilized': true,
      'color': Colors.amber,
      'icon': Icons.pets,
    },
    {
      'name': 'Bella',
      'breed': 'Persa',
      'gender': 'Hembra',
      'age': 1,
      'weight': '3.2 kg',
      'birthDate': '05/12/2022',
      'microchip': true,
      'microchipNumber': '#11223344',
      'sterilized': false,
      'color': Colors.teal,
      'icon': Icons.pets,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Ajusta el margen horizontal
          child: const Text(
            'Mis Mascotas',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/', // Ruta definida en la configuración de rutas
                      (route) => false,
                );
              },
            ),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                // Navegar a detalles de la mascota
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con avatar, nombre y edit icon
                    Row(
                      children: [
                        // Avatar de la mascota
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: pet['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            pet['icon'],
                            size: 30,
                            color: pet['color'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Nombre y raza
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet['name'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pet['breed'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${pet['gender']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${pet['age']} años',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.purple[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                ],
                              )

                            ],
                          ),
                        ),
                        // Edit icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Información en dos columnas
                    Row(
                      children: [
                        // Columna izquierda
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Peso
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peso',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pet['weight'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Microchip
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Microchip',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pet['microchip'] ? 'Sí' : 'No',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (pet['microchip'] && pet['microchipNumber'].isNotEmpty)
                                    Text(
                                      pet['microchipNumber'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Columna derecha
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fecha de nacimiento
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fecha de',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'nacimiento',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pet['birthDate'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Esterilizado
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Esterilizado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pet['sterilized'] ? 'Sí' : 'No',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navegar a historial
                            },
                            icon: Icon(
                              Icons.history,
                              size: 18,
                              color: Colors.blue[600],
                            ),
                            label: Text(
                              'Historial',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue[600]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navegar a citas
                            },
                            icon: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.blue[600],
                            ),
                            label: Text(
                              'Citas',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue[600]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Agregar nueva mascota
        },
      ),
    );
  }
}
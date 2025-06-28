// lib/ui/pages/pets/pets_screen.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../data/service/notification_service.dart';
import '../../../domain/entities/pet.dart';
import '../pet_form_screen.dart';
import 'pet_history.dart';
import 'pet_appointments.dart';
import 'pet_edit.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {

  final localStorageService = LocalStorageService();
  List<Pet> pets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loadedPets = await localStorageService.getAllPets();
      setState(() {
        pets = loadedPets;
      });
    } catch (e) {
      print('Error al cargar mascotas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para obtener el icono según el tipo de mascota
  IconData _getPetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'perro':
        return Icons.pets;
      case 'gato':
        return Icons.pets;
      case 'ave':
      case 'pájaro':
        return Icons.flutter_dash;
      case 'pez':
        return Icons.water_drop;
      case 'conejo':
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
  }

  // Función para obtener el color según el tipo de mascota
  Color _getPetColor(String type) {
    switch (type.toLowerCase()) {
      case 'perro':
        return Colors.brown;
      case 'gato':
        return Colors.orange;
      case 'ave':
      case 'pájaro':
        return Colors.blue;
      case 'pez':
        return Colors.teal;
      case 'conejo':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }


  Map<String, String> singularUnits = {
    'años': 'año',
    'meses': 'mes',
    'días': 'día',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
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
                _showLogoutDialog(context);
              },
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pets.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes mascotas registradas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primera mascota',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPets,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final petColor = _getPetColor(pet.type);
                final petIcon = _getPetIcon(pet.type);

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
                              color: petColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              petIcon,
                              size: 30,
                              color: petColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Nombre y raza
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        pet.type,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${pet.age} ${pet.age == 1 ? singularUnits[pet.timeUnit] ?? pet.timeUnit : pet.timeUnit}',
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
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetEdit(pet: pet),
                                ),
                              );

                              // Si se editó o eliminó la mascota, recargar la lista
                              if (result == true) {
                                _loadPets();
                              }
                            },
                            child: Container(
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
                          )
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
                                      '${pet.weight} kg',
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

                          // Columna derecha
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Genero
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sexo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${pet.gender}',
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PetHistory(petId: pet.id), // ← Asegúrate de tener pet.id disponible en este contexto
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.history,
                                size: 18,
                                color: Colors.blue[600],
                              ),
                              label: Text(
                                'Historial médico',
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PetAppointments(petId: pet.id), // ← Asegúrate de tener pet.id disponible en este contexto
                                  ),
                                );
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final Pet? newPet = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PetFormScreen(isFirstTime: false),
            ),
          );

          if (newPet != null) {
            setState(() {
              pets.add(newPet);
            });
            // O si prefieres mantener sincronizado con el almacenamiento local:
            // await _loadPets();
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop();
                await NotificationService.clearSession();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
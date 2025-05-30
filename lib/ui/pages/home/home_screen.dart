import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header con degradado
          _buildGradientHeader(),
          // Cuerpo con carrusel y recordatorios
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carrusel de mascotas
                  _buildPetsCarousel(),
                  const SizedBox(height: 24),
                  // Próximos recordatorios
                  const Text(
                    'Próximos recordatorios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRemindersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF8158B7), // #8158b7
            Color(0xFF35B4DD), // #35b4dd
            Color(0xFF40D1B6), // #40d1b6
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda con saludo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hola María',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenida a PetVital',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Icono de notificaciones
              GestureDetector(
                onTap: () {
                  setState(() {
                    _notificationsOn = !_notificationsOn;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _notificationsOn ? Icons.notifications_active : Icons.notifications_off,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetsCarousel() {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: 3, // Número de mascotas
        padEnds: false,
        controller: PageController(viewportFraction: 0.99),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF9a5af7).withOpacity(0.8),
                                Color(0xFF497cf6).withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Container(width: 17),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPetName(index),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getPetBreed(index),
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard(Icons.favorite, "Salud", Colors.redAccent),
                    _buildInfoCard(Icons.calendar_today, "Citas", Colors.blueAccent),
                    _buildInfoCard(Icons.pets, "Actividad", Colors.greenAccent),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, Color color) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return Column(
      children: [
        _buildReminderCard(
          title: 'Vacuna antirrábica',
          time: 'Mañana · 10:00 AM',
          color: const Color(0xFF8158B7),
          icon: Icons.medical_services,
        ),
        const SizedBox(height: 12),
        _buildReminderCard(
          title: 'Baño y peluquería',
          time: 'Viernes · 15:00 PM',
          color: const Color(0xFF35B4DD),
          icon: Icons.shower,
        ),
        const SizedBox(height: 12),
        _buildReminderCard(
          title: 'Control veterinario',
          time: 'Lunes · 09:30 AM',
          color: const Color(0xFF40D1B6),
          icon: Icons.local_hospital,
        ),
      ],
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para datos de ejemplo
  String _getPetName(int index) {
    final names = ['Max', 'Luna', 'Rocky'];
    return names[index % names.length];
  }

  String _getPetBreed(int index) {
    final breeds = ['Labrador', 'Persa', 'Bulldog Francés'];
    return breeds[index % breeds.length]+" - "+"3 años";
  }
}
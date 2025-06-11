import 'package:flutter/material.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/appointment_filter.dart';
import '../../../application/get_home_data_use_case.dart';
import '../../../domain/entities/homeResponse.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/appointment.dart';
import '../../../main.dart';
import '../pets/pet_appointments.dart';
import '../appointments/appointments_details_screen.dart';
import '../pets/pet_history.dart';
import '../../../core/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String? errorMessage;
  HomeResponse? homeData;
  User? currentUser;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Obtener usuario actual
      final user = await _storageService.getCurrentUser();

      final getHomeDataUseCase = getIt<GetHomeDataUseCase>();
      final HomeResponse? homeResponse = await getHomeDataUseCase.getHomeData();

      if (homeResponse != null) {
        setState(() {
          currentUser = user;
          homeData = homeResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar los datos';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  // MÉTODO PARA REFRESCAR LOS DATOS
  Future<void> _refreshData() async {
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData, // Pull to refresh
        child: Column(
          children: [
            // Header con degradado
            _buildGradientHeader(),
            // Cuerpo con carrusel y recordatorios
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Necesario para RefreshIndicator
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
                    Text(
                      'Hola ${currentUser?.firstName ?? 'Usuario'}',
                      style: const TextStyle(
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
              // Botón de planes premium con ícono de corona
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/premiumPlans');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(9, 8, 10, 8), // Más espacio a la derecha
                    child: Icon(
                      FontAwesomeIcons.crown,
                      color: Color(0xFFFFFFFF),
                      size: 20,
                    ),
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
    if (isLoading) {
      return _buildPetsLoadingCarousel();
    }

    if (errorMessage != null) {
      return _buildErrorWidget(errorMessage!);
    }

    if (homeData == null || homeData!.pets.isEmpty) {
      return _buildNoPetsWidget();
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: homeData!.pets.length,
        padEnds: false,
        controller: PageController(viewportFraction: 0.99),
        itemBuilder: (context, index) {
          final pet = homeData!.pets[index];
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                        Container(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${pet.type} - ${pet.age} ${_formatTimeUnit(pet.timeUnit, pet.age)}',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard(Icons.favorite, "Salud", Colors.redAccent, pet),
                    _buildInfoCard(Icons.calendar_today, "Citas", Colors.blueAccent, pet),
                    _buildInfoCard(Icons.pets, "Actividad", Colors.greenAccent, pet),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeUnit(String timeUnit, int age) {
    if (age == 1) {
      switch (timeUnit.toLowerCase()) {
        case 'años':
          return 'año';
        case 'meses':
          return 'mes';
        case 'días':
          return 'día';
        default:
          return timeUnit; // En caso de un valor inesperado
      }
    }
    return timeUnit.toLowerCase();
  }

  Widget _buildPetsLoadingCarousel() {
    return SizedBox(
      height: 220,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8158B7)),
              ),
              SizedBox(height: 16),
              Text(
                'Cargando mascotas...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPetsWidget() {
    return SizedBox(
      height: 220,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No tienes mascotas registradas',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Agrega tu primera mascota',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, Color color, Pet pet) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case "Salud":
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.main,
                  (route) => false,
              arguments: {
                'initialIndex': 2,
                'pet': pet, // 👈 Aquí pasas el objeto Pet completo
              },
            );
            break;
          case "Citas":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetAppointments(petId: pet.id),
              ),
            );
            break;
          case "Actividad":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetHistory(petId: pet.id),
              ),
            );
            break;
          default:
            break;
        }
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRemindersList() {
    if (isLoading) {
      return _buildRemindersLoadingList();
    }

    if (errorMessage != null) {
      return _buildErrorWidget(errorMessage!);
    }

    if (homeData == null || homeData!.appointments.isEmpty) {
      return _buildNoRemindersWidget();
    }

    // Filtrar solo las citas futuras usando AppointmentFilter
    final futureAppointments = AppointmentFilter.filterFutureAppointments(
      appointments: homeData!.appointments,
    );

    // Si no hay citas futuras, mostrar widget de "no hay citas"
    if (futureAppointments.isEmpty) {
      return _buildNoRemindersWidget();
    }

    return Column(
      children: futureAppointments.map((appointment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReminderCard(
              title: appointment.name,
              time: DateTimeUtils.formatDateTime(appointment.date, appointment.time),
              color: _getColorForReminderType(appointment.type),
              icon: _getIconForReminderType(appointment.type),
              appointment: appointment
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRemindersLoadingList() {
    return Column(
      children: List.generate(3, (index) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cargando citas...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Por favor espera',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildNoRemindersWidget() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No tienes citas programadas',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Agenda tu primera cita',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String time,
    required Color color,
    required IconData icon,
    required Appointment appointment
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
          GestureDetector(
            onTap: () async {
              // AQUÍ ES LA MAGIA: Esperar el resultado cuando regreses
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentsDetailsScreen(appointment: appointment),
                ),
              );

              // Si se eliminó la cita (result == true), refresca los datos
              if (result == true) {
                await _refreshData();
              }
            },
            child: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForReminderType(String type) {
    switch (type.toLowerCase()) {
      case 'vacuna':
        return const Color(0xFF8158B7);
      case 'baño':
      case 'peluquería':
        return const Color(0xFF35B4DD);
      case 'control':
      case 'consulta':
        return const Color(0xFF40D1B6);
      default:
        return const Color(0xFF8158B7);
    }
  }

  IconData _getIconForReminderType(String type) {
    switch (type.toLowerCase()) {
      case 'vacuna':
        return Icons.medical_services;
      case 'baño':
      case 'peluquería':
        return Icons.shower;
      case 'control':
      case 'consulta':
        return Icons.local_hospital;
      default:
        return Icons.event;
    }
  }
}
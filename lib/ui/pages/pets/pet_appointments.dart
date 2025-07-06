import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../application/get_pet_appointments_use_case.dart';
import '../../../domain/entities/appointment.dart';
import '../../../core/utils/appointment_filter.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../main.dart';

class PetAppointments extends StatefulWidget {
  final int petId;

  const PetAppointments({
    super.key,
    required this.petId,
  });

  @override
  State<PetAppointments> createState() => _PetAppointmentsState();
}

class _PetAppointmentsState extends State<PetAppointments> {
  bool isLoading = true;
  String? errorMessage;
  List<Appointment> futureAppointments = [];
  List<Appointment> pastAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final appointmentsUseCase = getIt<GetPetAppointmentsUseCase>();
      final allAppointments = await appointmentsUseCase.getPetAppointments(widget.petId);

      if (allAppointments != null) {
        // Separar citas futuras y pasadas
        final separatedAppointments = _separateAppointments(allAppointments);

        setState(() {
          futureAppointments = separatedAppointments['future']!;
          pastAppointments = separatedAppointments['past']!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No se pudieron cargar las citas';
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        errorMessage = 'Error al cargar las citas: $e';
        isLoading = false;
      });
    }
  }

  Map<String, List<Appointment>> _separateAppointments(List<Appointment> allAppointments) {
    final now = DateTime.now();
    final future = <Appointment>[];
    final past = <Appointment>[];

    for (final appointment in allAppointments) {
      try {
        final datePart = DateTime.parse(appointment.date);
        final timeParts = appointment.time.split(':');
        final fullDateTime = DateTime(
          datePart.year,
          datePart.month,
          datePart.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );

        if (fullDateTime.isAfter(now) || fullDateTime.isAtSameMomentAs(now)) {
          future.add(appointment);
        } else {
          past.add(appointment);
        }
      } catch (e) {
        print('Error parsing appointment date/time: $e');
      }
    }

    // Ordenar citas futuras (ascendente - más próximas primero)
    future.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final timePartsA = a.time.split(':');
        final fullDateTimeA = DateTime(
          dateA.year,
          dateA.month,
          dateA.day,
          int.parse(timePartsA[0]),
          int.parse(timePartsA[1]),
          timePartsA.length > 2 ? int.parse(timePartsA[2]) : 0,
        );

        final dateB = DateTime.parse(b.date);
        final timePartsB = b.time.split(':');
        final fullDateTimeB = DateTime(
          dateB.year,
          dateB.month,
          dateB.day,
          int.parse(timePartsB[0]),
          int.parse(timePartsB[1]),
          timePartsB.length > 2 ? int.parse(timePartsB[2]) : 0,
        );

        return fullDateTimeA.compareTo(fullDateTimeB);
      } catch (e) {
        return 0;
      }
    });

    // Ordenar citas pasadas (descendente - más recientes primero)
    past.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final timePartsA = a.time.split(':');
        final fullDateTimeA = DateTime(
          dateA.year,
          dateA.month,
          dateA.day,
          int.parse(timePartsA[0]),
          int.parse(timePartsA[1]),
          timePartsA.length > 2 ? int.parse(timePartsA[2]) : 0,
        );

        final dateB = DateTime.parse(b.date);
        final timePartsB = b.time.split(':');
        final fullDateTimeB = DateTime(
          dateB.year,
          dateB.month,
          dateB.day,
          int.parse(timePartsB[0]),
          int.parse(timePartsB[1]),
          timePartsB.length > 2 ? int.parse(timePartsB[2]) : 0,
        );

        return fullDateTimeB.compareTo(fullDateTimeA);
      } catch (e) {
        return 0;
      }
    });

    return {'future': future, 'past': past};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Citas de Mascota',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: Skeletonizer(
        enabled: isLoading,
        child: isLoading
            ? _buildSkeletonContent()
            : errorMessage != null
            ? _buildErrorWidget(errorMessage!)
            : _buildContent(),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton para sección de Próximas Citas
          _buildSectionHeader(
            icon: Icons.schedule,
            iconColor: Colors.blue[600]!,
            title: 'Próximos recordatorios',
          ),
          const SizedBox(height: 16),
          _buildSkeletonAppointmentsSection(),

          const SizedBox(height: 32),

          // Skeleton para sección de Historial
          _buildSectionHeader(
            icon: Icons.history,
            iconColor: Colors.grey[600]!,
            title: 'Historial de citas completadas',
          ),
          const SizedBox(height: 16),
          _buildSkeletonAppointmentsSection(),
        ],
      ),
    );
  }

  Widget _buildSkeletonAppointmentsSection() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSkeletonAppointmentCard(),
        );
      }),
    );
  }

  Widget _buildSkeletonAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Colors.grey[300]!,
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
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 13,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las citas',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Próximas Citas
          _buildSectionHeader(
            icon: Icons.schedule,
            iconColor: Colors.blue[600]!,
            title: 'Próximos recordatorios',
          ),
          const SizedBox(height: 16),
          _buildFutureAppointmentsSection(),

          const SizedBox(height: 32),

          // Sección de Historial
          _buildSectionHeader(
            icon: Icons.history,
            iconColor: Colors.grey[600]!,
            title: 'Historial de citas completadas',
          ),
          const SizedBox(height: 16),
          _buildPastAppointmentsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildFutureAppointmentsSection() {
    if (futureAppointments.isEmpty) {
      return _buildNoFutureAppointmentsWidget();
    }

    return Column(
      children: futureAppointments.map((appointment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFutureAppointmentCard(
            title: appointment.name,
            date: appointment.date,
            time: appointment.time,
            type: appointment.type,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPastAppointmentsSection() {
    if (pastAppointments.isEmpty) {
      return _buildNoPastAppointmentsWidget();
    }

    return Column(
      children: pastAppointments.map((appointment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPastAppointmentCard(
            title: appointment.name,
            time: DateTimeUtils.formatDateTime(appointment.date, appointment.time),
            type: appointment.type,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoFutureAppointmentsWidget() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Sin citas programadas',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No hay citas futuras\nprogramadas para esta mascota',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPastAppointmentsWidget() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_edu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Sin historial de citas',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no hay citas completadas\npara esta mascota',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureAppointmentCard({
    required String title,
    required String date,
    required String time,
    required String type,
  }) {
    final Color cardColor = _getCardColorForType(type);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: cardColor,
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
              color: cardColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(type),
              color: cardColor,
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateTimeUtils.formatDate(date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateTimeUtils.formatTime(time),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildPastAppointmentCard({
    required String title,
    required String time,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Colors.grey[400]!,
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
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(type),
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.history,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getCardColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'vacuna':
        return Colors.green;
      case 'baño':
      case 'peluquería':
        return Colors.blue;
      case 'control':
      case 'consulta':
        return Colors.orange;
      case 'medicamento':
        return Colors.purple;
      case 'cirugia':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'vacuna':
        return Icons.vaccines;
      case 'baño':
      case 'peluquería':
        return Icons.shower;
      case 'control':
      case 'consulta':
        return Icons.local_hospital;
      case 'medicamento':
        return Icons.medication;
      case 'cirugia':
        return Icons.healing;
      default:
        return Icons.medical_services;
    }
  }
}
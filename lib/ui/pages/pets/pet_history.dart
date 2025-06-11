import 'package:flutter/material.dart';
import '../../../application/get_pet_appointments_use_case.dart';
import '../../../domain/entities/appointment.dart';
import '../../../core/utils/appointment_filter.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../main.dart';

class PetHistory extends StatefulWidget {
  final int petId;

  const PetHistory({
    super.key,
    required this.petId,
  });

  @override
  State<PetHistory> createState() => _PetHistoryState();
}

class _PetHistoryState extends State<PetHistory> {
  bool isLoading = true;
  String? errorMessage;
  List<Appointment> appointments = [];

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
        // Filtrar solo citas pasadas (anteriores a la fecha/hora actual)
        final pastAppointments = _filterPastAppointments(allAppointments);

        setState(() {
          appointments = pastAppointments;
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

  List<Appointment> _filterPastAppointments(List<Appointment> allAppointments) {
    final now = DateTime.now();
    final pastAppointments = <Appointment>[];

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

        if (fullDateTime.isBefore(now)) {
          pastAppointments.add(appointment);
        }
      } catch (e) {
        print('Error parsing appointment date/time: $e');
      }
    }

    // Ordenar de más reciente a más antigua (descendente)
    pastAppointments.sort((a, b) {
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

        return fullDateTimeB.compareTo(fullDateTimeA); // Orden descendente
      } catch (e) {
        return 0;
      }
    });

    return pastAppointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Historial de Citas',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Historial de citas completadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (isLoading) {
      return _buildHistoryLoadingList();
    }

    if (errorMessage != null) {
      return _buildErrorWidget(errorMessage!);
    }

    if (appointments.isEmpty) {
      return _buildNoHistoryWidget();
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHistoryCard(
            title: appointment.name,
            time: DateTimeUtils.formatDateTime(appointment.date, appointment.time),
            type: appointment.type,
            isCompleted: true,
          ),
        );
      },
    );
  }

  Widget _buildHistoryLoadingList() {
    return Column(
      children: List.generate(4, (index) =>
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
                          'Cargando historial...',
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

  Widget _buildNoHistoryWidget() {
    return Center(
      child: Container(
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
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
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
            const SizedBox(width: 16),
            Text(
              'Error al cargar el historial',
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

  Widget _buildHistoryCard({
    required String title,
    required String time,
    required String type,
    required bool isCompleted,
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
              _getHistoryIconForType(type),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completado',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  IconData _getHistoryIconForType(String type) {
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
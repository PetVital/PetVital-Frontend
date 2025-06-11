import 'package:flutter/material.dart';
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
        // Filtrar solo citas futuras (posteriores o iguales a la fecha/hora actual)
        final futureAppointments = _filterFutureAppointments(allAppointments);

        setState(() {
          appointments = futureAppointments;
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

  List<Appointment> _filterFutureAppointments(List<Appointment> allAppointments) {
    // Usar AppointmentFilter para filtrar citas futuras
    return AppointmentFilter.filterFutureAppointments(
      appointments: allAppointments,
      fromDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Próximas Citas',
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
                  Icons.schedule,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Próximos recordatorios',
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
              child: _buildAppointmentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (isLoading) {
      return _buildAppointmentsLoadingList();
    }

    if (errorMessage != null) {
      return _buildErrorWidget(errorMessage!);
    }

    if (appointments.isEmpty) {
      return _buildNoAppointmentsWidget();
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAppointmentCard(
            title: appointment.name,
            date: appointment.date,
            time: appointment.time,
            type: appointment.type,
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsLoadingList() {
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
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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

  Widget _buildNoAppointmentsWidget() {
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

  Widget _buildAppointmentCard({
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
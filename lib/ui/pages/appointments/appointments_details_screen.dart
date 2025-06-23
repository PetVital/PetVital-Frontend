import 'package:flutter/material.dart';
import '../../../domain/entities/appointment.dart';
import '../../../application/delete_appointment_use_case.dart';
import '../../../domain/entities/pet.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../main.dart';
import '../../../data/service/notification_service.dart';

class AppointmentsDetailsScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentsDetailsScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentsDetailsScreen> createState() => _AppointmentsDetailsScreenState();
}

class _AppointmentsDetailsScreenState extends State<AppointmentsDetailsScreen> {
  final localStorageService = LocalStorageService();
  Pet? _pet;
  bool _isLoadingPet = true;
  bool _isLoading = false;

  final List<AppointmentType> _appointmentTypes = [
    AppointmentType('Vacuna', Icons.vaccines, Colors.purple),
    AppointmentType('Baño', Icons.bathtub, Colors.blue),
    AppointmentType('Medicina', Icons.medical_services, Colors.teal),
    AppointmentType('Otro', Icons.add, Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    setState(() {
      _isLoadingPet = true;
    });

    try {
      final pet = await localStorageService.getPetById(widget.appointment.petId);
      setState(() {
        _pet = pet;
        _isLoadingPet = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPet = false;
      });
      print('Error al cargar la mascota: $e');
    }
  }

  // Función para obtener el ícono y color según el tipo de cita
  AppointmentType _getAppointmentTypeInfo(String type) {
    return _appointmentTypes.firstWhere(
          (appointmentType) => appointmentType.name == type,
      orElse: () => AppointmentType('Otro', Icons.add, Colors.grey),
    );
  }

  // Función para formatear la fecha de yyyy-mm-dd a dd/mm/yyyy
  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  // Función para convertir de formato 24h a 12h
  String _formatTime(String time24h) {
    try {
      final parts = time24h.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];

        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        return '${hour.toString().padLeft(2, '0')}:$minute $period';
      }
      return time24h;
    } catch (e) {
      return time24h;
    }
  }

  Future<void> _deleteAppointment() async {
    print("APPOINTMENT");
    print(widget.appointment.id);
    try {
      setState(() {
        _isLoading = true;
      });

      // 🔥 Primero cancelar la notificación
      final notificationCanceled = await NotificationService.cancelAppointmentNotification(
          widget.appointment.id.toString()
      );

      if (!notificationCanceled) {
        setState(() {
          _isLoading = false;
        });
        _showError('No se pudo cancelar la notificación. La eliminación fue cancelada.');
        return;
      }

      // ✅ Si la notificación se canceló correctamente, proceder con el use case
      final deleteAppointmentUseCase = getIt<DeleteAppointmentUseCase>();
      final success = await deleteAppointmentUseCase.deleteAppointment(widget.appointment.id);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccess("Cita eliminada exitosamente");
        Navigator.pop(context, true);
      } else {
        _showError('No se pudo eliminar la cita. Intenta nuevamente.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al eliminar la cita: ${e.toString()}');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final appointmentTypeInfo = _getAppointmentTypeInfo(widget.appointment.type);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles de la Cita',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono del tipo de cita
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: appointmentTypeInfo.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      appointmentTypeInfo.icon,
                      size: 40,
                      color: appointmentTypeInfo.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.appointment.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: appointmentTypeInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.appointment.type,
                      style: TextStyle(
                        fontSize: 14,
                        color: appointmentTypeInfo.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información de la cita
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la Cita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mascota
                  _buildInfoRow(
                    'Mascota',
                    _isLoadingPet
                        ? 'Cargando...'
                        : (_pet != null ? '${_pet!.name} (${_pet!.type})' : 'No encontrada'),
                    Icons.pets,
                    Colors.orange,
                  ),

                  const SizedBox(height: 16),

                  // Fecha
                  _buildInfoRow(
                    'Fecha',
                    _formatDate(widget.appointment.date),
                    Icons.calendar_today,
                    Colors.blue,
                  ),

                  const SizedBox(height: 16),

                  // Hora
                  _buildInfoRow(
                    'Hora',
                    _formatTime(widget.appointment.time),
                    Icons.access_time,
                    Colors.green,
                  ),

                  if (widget.appointment.note.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Notas',
                      widget.appointment.note,
                      Icons.note,
                      Colors.purple,
                    ),
                  ],

                  if (widget.appointment.reminder.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Recordatorio',
                      widget.appointment.reminder,
                      Icons.notifications,
                      Colors.amber,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                /*Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar edición de cita
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de editar en desarrollo'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.blue[600],
                    ),
                    label: Text(
                      'Editar',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),*/
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmationDialog();
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Eliminar cita?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Esta acción no se puede deshacer.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAppointment();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

}

// Clase auxiliar (si no la tienes ya en otro archivo)
class AppointmentType {
  final String name;
  final IconData icon;
  final Color color;

  AppointmentType(this.name, this.icon, this.color);
}
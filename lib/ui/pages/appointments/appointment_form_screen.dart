import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/appointment.dart';
import '../../../application/get_user_pets_use_case.dart';
import '../../../application/add_appointment_use_case.dart';
import '../../../data/service/notification_service.dart';
import '../../../main.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';


class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen({super.key});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedAppointmentType = 'Vacuna';
  Pet? _selectedPet;
  List<Pet>? _pets;
  bool _isLoadingPets = false;
  bool _isLoading = false;
  String? _selectedReminder = '1 día antes';

  final List<AppointmentType> _appointmentTypes = [
    AppointmentType('Vacuna', Icons.vaccines, Colors.purple),
    AppointmentType('Baño', Icons.bathtub, Colors.blue),
    AppointmentType('Medicina', Icons.medical_services, Colors.teal),
    AppointmentType('Otro', Icons.add, Colors.grey),
  ];

  final List<String> _reminderOptions = [
    'Sin recordatorio',
    '30 minutos antes',
    '1 hora antes',
    '1 día antes',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    setState(() {
      _isLoadingPets = true;
    });

    try {
      final getUserPetsUseCase = getIt<GetUserPetsUseCase>();
      final pets = await getUserPetsUseCase.getUserPets();
      setState(() {
        _pets = pets;
        _isLoadingPets = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPets = false;
      });
      // Handle error
      print('Error loading pets: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF8C52FF), // Color de botones y texto resaltado
              onPrimary: Colors.white, // Color del texto de botones
              surface: Colors.white,
              onSurface: Color(0xFF1E1E1E),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _selectTime() async {
    DateTime selectedTime = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Seleccionar hora',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: SizedBox(
            height: 200,
            child: TimePickerSpinner(
              time: selectedTime,
              is24HourMode: false,
              normalTextStyle: const TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
              highlightedTextStyle: const TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              spacing: 50,
              itemHeight: 60,
              isForce2Digits: true,
              onTimeChange: (time) {
                selectedTime = time;
              },
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
                final hour = selectedTime.hour > 12
                    ? selectedTime.hour - 12
                    : (selectedTime.hour == 0 ? 12 : selectedTime.hour);
                final period = selectedTime.hour >= 12 ? 'PM' : 'AM';
                _timeController.text = '${hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} $period';
                Navigator.of(context).pop();
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Color(0xFF8C52FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _convertTo24Hour(String time12h) {
    final parts = time12h.split(' ');
    final timePart = parts[0];
    final period = parts[1];

    final hourMinute = timePart.split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = hourMinute[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute:00';
  }

  DateTime _buildAppointmentDateTime(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      int.parse(timeParts[2]),
    );
  }

  DateTime _calculateNotificationDateTime(DateTime appointmentDateTime, String reminderType) {
    switch (reminderType) {
      case '30 minutos antes':
        return appointmentDateTime.subtract(const Duration(minutes: 30));
      case '1 hora antes':
        return appointmentDateTime.subtract(const Duration(hours: 1));
      case '1 día antes':
        return appointmentDateTime.subtract(const Duration(days: 1));
      default:
        return appointmentDateTime.subtract(const Duration(minutes: 30));
    }
  }

  bool _isNotificationTimeValid(String date, String time, String reminderType) {
    // Si no hay recordatorio, siempre es válido
    if (reminderType == 'Sin recordatorio') {
      return true;
    }

    try {
      // Construir DateTime de la cita
      final appointmentDateTime = _buildAppointmentDateTime(date, time);

      // Calcular cuando será la notificación
      final notificationDateTime = _calculateNotificationDateTime(appointmentDateTime, reminderType);

      // Verificar que la notificación sea en el futuro
      return notificationDateTime.isAfter(DateTime.now());
    } catch (e) {
      print('Error al validar tiempo de notificación: $e');
      return false;
    }
  }

// Función para obtener mensaje de error específico
  String _getNotificationTimeErrorMessage(String reminderType) {
    switch (reminderType) {
      case '30 minutos antes':
        return 'La hora de la cita debe ser al menos 30 minutos después de ahora para poder programar el recordatorio.';
      case '1 hora antes':
        return 'La hora de la cita debe ser al menos 1 hora después de ahora para poder programar el recordatorio.';
      case '1 día antes':
        return 'La fecha de la cita debe ser al menos 1 día después de hoy para poder programar el recordatorio.';
      default:
        return 'No se puede programar el recordatorio para esta fecha y hora.';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Convertir fecha de dd/mm/yyyy a yyyy-mm-dd
        final dateParts = _dateController.text.trim().split('/');
        final formattedDate = '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';

        // Convertir hora de 12h a 24h format
        final timeText = _timeController.text.trim();
        final formattedTime = _convertTo24Hour(timeText);

        // 🔥 VALIDAR TIEMPO DE NOTIFICACIÓN ANTES DE CONTINUAR
        if (!_isNotificationTimeValid(formattedDate, formattedTime, _selectedReminder ?? '')) {
          setState(() {
            _isLoading = false;
          });

          // Mostrar mensaje de error específico
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getNotificationTimeErrorMessage(_selectedReminder ?? '')),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
          return; // Salir sin guardar
        }

        // Construir el objeto Appointment
        final appointment = Appointment(
          id: 0, // El ID será asignado por el backend
          type: _selectedAppointmentType!, // tipo_recordatorio
          name: _titleController.text.trim(), // nombre
          date: formattedDate, // fecha en formato yyyy-mm-dd
          time: formattedTime, // hora en formato 24h
          note: _notesController.text.trim().isEmpty ? '' : _notesController.text.trim(), // nota (puede estar vacía)
          reminder: _selectedReminder ?? '', // recordatorio seleccionado
          petId: _selectedPet!.id, // mascota.id
        );

        // Enviar al backend usando AddAppointmentUseCase
        final addAppointmentUseCase = getIt<AddAppointmentUseCase>();
        final appointmentResponse = await addAppointmentUseCase.addAppointment(appointment);

        if (appointmentResponse != null) {
          // ✨ PROGRAMAR NOTIFICACIÓN PUSH CON ONESIGNAL ✨
          try {
            final notificationTitle = 'Recordatorio de ${appointment.type}';
            final notificationMessage = NotificationService.generateNotificationMessage(
              petName: _selectedPet!.name,
              appointmentType: appointment.type,
              reminderType: appointment.reminder,
            );

            final notificationSuccess = await NotificationService.scheduleAppointmentNotification(
              appointmentDate: appointment.date,
              appointmentTime: appointment.time,
              reminderType: appointment.reminder,
              title: notificationTitle,
              message: notificationMessage,
              petName: _selectedPet!.name,
              appointmentType: appointment.type,
              additionalData: {
                'route': '/appointment_details',
                'appointment_id': appointmentResponse.id.toString(),
                'pet_id': _selectedPet!.id.toString(),
                'type': 'appointment_reminder',
              },
              appointmentId: appointmentResponse.id.toString(),
            );

            if (notificationSuccess) {
              print('✅ Notificación programada correctamente');
            } else {
              print('⚠️ Error al programar la notificación, pero la cita se guardó');
            }
          } catch (notificationError) {
            print('❌ Error en notificación: $notificationError');
          }

          setState(() {
            _isLoading = false;
          });

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  _selectedReminder == 'Sin recordatorio'
                      ? 'Cita guardada exitosamente'
                      : 'Cita guardada y recordatorio programado'
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar de vuelta
          Navigator.pop(context, true);

        } else {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar la cita. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );

        print('Error al guardar la cita: $e');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva Cita',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de cita
              const Text(
                'Tipo de cita',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _appointmentTypes.map((type) {
                  final isSelected = _selectedAppointmentType == type.name;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAppointmentType = type.name;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? type.color : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type.icon,
                              color: isSelected ? Colors.white : Colors.grey[600],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Título
              const Text(
                'Título',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el título de la cita';
                  } else if (value.trim().length < 3) {
                    return 'El título debe tener al menos 3 caracteres';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ej: Cita de control',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mascota
              const Text(
                'Mascota',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField2<Pet>(
                isExpanded: true,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                hint: Text(
                  _isLoadingPets
                      ? 'Cargando mascotas...'
                      : 'Selecciona una mascota',
                  style: const TextStyle(color: Colors.grey),
                ),
                items: _pets?.map((Pet pet) {
                  return DropdownMenuItem<Pet>(
                    value: pet,
                    child: Text(
                      '${pet.name} (${pet.type})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una mascota';
                  }
                  return null;
                },
                onChanged: _isLoadingPets ? null : (Pet? value) {
                  setState(() {
                    _selectedPet = value;
                  });
                },
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    color: Colors.white, // fondo blanco para la lista desplegable
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fecha
              const Text(
                'Fecha',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor selecciona una fecha';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'dd/mm/aaaa',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey[100],
                  filled: true,
                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hora
              const Text(
                'Hora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor selecciona una hora';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '--:--',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey[100],
                  filled: true,
                  suffixIcon: const Icon(Icons.access_time, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Recordatorio
              const Text(
                'Recordatorio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField2<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                hint: const Text(
                  'Selecciona recordatorio',
                  style: TextStyle(color: Colors.grey),
                ),
                value: _selectedReminder,
                items: _reminderOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedReminder = value;
                  });
                },
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Notas (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Agrega detalles',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _isLoading
                        ? null
                        : const LinearGradient(
                      colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: _isLoading ? const Color(0xFFE5E5E5) : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.transparent,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Guardar Cita',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
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
}

// Clases auxiliares
class AppointmentType {
  final String name;
  final IconData icon;
  final Color color;

  AppointmentType(this.name, this.icon, this.color);
}
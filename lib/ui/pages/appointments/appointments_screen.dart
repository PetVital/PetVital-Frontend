import 'package:flutter/material.dart';
import 'appointment_form_screen.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/pet.dart';
import '../../../application/get_user_appointmets_use_case.dart';
import '../../../application/get_user_pets_use_case.dart';
import '../../../core/utils/appointment_filter.dart';
import '../../../main.dart';
// Importar el transformador que creamos
import '../../../domain/entities/appointmentTransformer.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime currentMonth = DateTime.now();

  // Datos reales
  List<Appointment> _appointments = [];
  List<Map<String, dynamic>> _calendarAppointmentsUIData = []; // TODAS las citas
  List<Map<String, dynamic>> _reminderAppointmentsUIData = []; // Solo citas futuras

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointmentsUseCase = getIt<GetUserAppointmentsUseCase>();
      final appointments = await appointmentsUseCase.getUserAppointments();

      final now = DateTime.now();

      // Filtrar solo citas futuras para los recordatorios
      final filteredAppointments = AppointmentFilter.filterFutureAppointments(
        appointments: appointments!,
        fromDate: now,
      );

      // Transformar TODAS las citas para el calendario
      final calendarUiData = await AppointmentTransformer.appointmentsToUIFormat(appointments);
      // Transformar solo las citas futuras para los recordatorios
      final reminderUiData = await AppointmentTransformer.appointmentsToUIFormat(filteredAppointments);

      setState(() {
        _appointments = filteredAppointments;
        _calendarAppointmentsUIData = calendarUiData; // TODAS las citas
        _reminderAppointmentsUIData = reminderUiData; // Solo citas futuras
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading appointments: $e'); // Debug
      setState(() {
        _errorMessage = 'Error al cargar las citas: $e';
        _isLoading = false;
      });
    }
  }

  // Método para refrescar datos
  Future<void> _refreshData() async {
    await _loadData();
  }

  // MÉTODO PARA EL CALENDARIO - USA TODAS LAS CITAS
  Map<int, List<Map<String, dynamic>>> getCalendarAppointmentsForMonth(DateTime month) {
    Map<int, List<Map<String, dynamic>>> monthAppointments = {};

    for (var appointment in _calendarAppointmentsUIData) { // USA TODAS LAS CITAS
      final appointmentDate = appointment['date'];
      if (appointmentDate['month'] == month.month &&
          appointmentDate['year'] == month.year) {

        final day = appointmentDate['day'];
        if (!monthAppointments.containsKey(day)) {
          monthAppointments[day] = [];
        }
        monthAppointments[day]!.add(appointment);
      }
    }

    return monthAppointments;
  }

  // MÉTODO PARA LOS RECORDATORIOS - USA SOLO CITAS FUTURAS
  Map<int, List<Map<String, dynamic>>> getReminderAppointmentsForMonth(DateTime month) {
    Map<int, List<Map<String, dynamic>>> monthAppointments = {};

    for (var appointment in _reminderAppointmentsUIData) { // USA SOLO CITAS FUTURAS
      final appointmentDate = appointment['date'];
      if (appointmentDate['month'] == month.month &&
          appointmentDate['year'] == month.year) {

        final day = appointmentDate['day'];
        if (!monthAppointments.containsKey(day)) {
          monthAppointments[day] = [];
        }
        monthAppointments[day]!.add(appointment);
      }
    }

    return monthAppointments;
  }

  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'medical_services':
        return Icons.medical_services;
      case 'vaccines':
        return Icons.vaccines;
      case 'monitor_weight':
        return Icons.monitor_weight;
      case 'bathtub':
        return Icons.bathtub;
      case 'pets':
        return Icons.pets;
      default:
        return Icons.event;
    }
  }

  Color getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Citas Veterinarias',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorWidget()
          : Column(
        children: [
          // Calendario
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildCalendarHeader(),
                _buildCalendarGrid(),
              ],
            ),
          ),
          // Lista de próximas citas
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Próximas citas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildAppointmentsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentFormScreen(),
            ),
          );

          // Si se guardó una cita exitosamente, recargar datos
          if (result == true) {
            _refreshData();
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: () {
              setState(() {
                currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
              });
            },
          ),
          Text(
            '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {
              setState(() {
                currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Encabezados de días
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          // Grid de días
          ..._buildCalendarWeeks(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;

    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    // Días del mes anterior
    final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1, 0);
    for (int i = firstDayWeekday - 1; i > 0; i--) {
      currentWeek.add(_buildCalendarDay(
        previousMonth.day - i + 1,
        isCurrentMonth: false,
      ));
    }

    // Días del mes actual
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      if (currentWeek.length == 7) {
        weeks.add(Row(children: currentWeek));
        currentWeek = [];
      }

      currentWeek.add(_buildCalendarDay(day, isCurrentMonth: true));
    }

    // Días del próximo mes
    while (currentWeek.length < 7) {
      currentWeek.add(_buildCalendarDay(
        currentWeek.length - (7 - firstDayWeekday) + 1,
        isCurrentMonth: false,
      ));
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(Row(children: currentWeek));
    }

    return weeks;
  }

  Widget _buildCalendarDay(int day, {required bool isCurrentMonth}) {
    // AQUÍ USA EL MÉTODO PARA EL CALENDARIO (TODAS LAS CITAS)
    final currentMonthAppointments = getCalendarAppointmentsForMonth(currentMonth);
    final hasAppointment = isCurrentMonth && currentMonthAppointments.containsKey(day);
    final isToday = isCurrentMonth &&
        day == DateTime.now().day &&
        currentMonth.month == DateTime.now().month &&
        currentMonth.year == DateTime.now().year;

    // Determinar si la cita es pasada o futura para diferentes colores
    Color appointmentColor = const Color(0xFF8158B7); // Color por defecto

    if (hasAppointment && isCurrentMonth) {
      final currentDate = DateTime(currentMonth.year, currentMonth.month, day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (currentDate.isBefore(today)) {
        // Cita pasada - color más tenue
        appointmentColor = Color(0xFFCCBFDF);
      } else {
        // Cita futura - color normal
        appointmentColor = const Color(0xFF8158B7);
      }
    }

    return Expanded(
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isCurrentMonth ? () {} : null,
            child: Container(
              decoration: BoxDecoration(
                color: hasAppointment
                    ? appointmentColor
                    : isToday
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isToday && !hasAppointment
                    ? Border.all(color: Colors.blue, width: 1)
                    : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: hasAppointment
                        ? Colors.white
                        : isCurrentMonth
                        ? isToday
                        ? Colors.blue
                        : const Color(0xFF2C3E50)
                        : Colors.grey[400],
                    fontSize: 16,
                    fontWeight: hasAppointment || isToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    // AQUÍ USA EL MÉTODO PARA LOS RECORDATORIOS (SOLO CITAS FUTURAS)
    final currentMonthAppointments = getReminderAppointmentsForMonth(currentMonth);
    List<Map<String, dynamic>> allAppointments = [];

    // Recopilar todas las citas futuras del mes
    currentMonthAppointments.forEach((day, dayAppointments) {
      allAppointments.addAll(dayAppointments);
    });

    // Ordenar las citas por día y hora
    allAppointments.sort((a, b) {
      final dateA = a['date'];
      final dateB = b['date'];

      // Primero ordenar por día
      final dayComparison = dateA['day'].compareTo(dateB['day']);
      if (dayComparison != 0) return dayComparison;

      // Si es el mismo día, ordenar por hora
      return a['time'].toString().compareTo(b['time'].toString());
    });

    if (allAppointments.isEmpty) {
      return const Center(
        child: Text(
          'No tienes citas próximas este mes',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: allAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointment: allAppointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard({
    required Map<String, dynamic> appointment,
  }) {
    final monthNames = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    final appointmentDate = appointment['date'];
    final day = appointmentDate['day'];
    final month = appointmentDate['month'];
    final appointmentColor = getColorFromHex(appointment['color']);
    final appointmentIcon = getIconFromString(appointment['icon']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appointmentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              appointmentIcon,
              color: appointmentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$day de ${monthNames[month - 1]} · ${appointment['time']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Para ${appointment['petName']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
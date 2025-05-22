import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime currentMonth = DateTime(2023, 6); // Junio 2023 como en la imagen

  // Datos de ejemplo de citas en formato JSON más común
  final List<Map<String, dynamic>> appointmentsData = [
    {
      'id': 1,
      'title': 'Revisión general',
      'time': '10:30 AM',
      'clinic': 'Clínica Veterinaria San Miguel',
      'date': {
        'day': 15,
        'month': 6,
        'year': 2023,
      },
      'icon': 'medical_services',
      'color': '#8158B7',
      'petName': 'Max',
    },
    {
      'id': 2,
      'title': 'Vacunación anual',
      'time': '2:00 PM',
      'clinic': 'Clínica Veterinaria San Miguel',
      'date': {
        'day': 21,
        'month': 6,
        'year': 2023,
      },
      'icon': 'vaccines',
      'color': '#8158B7',
      'petName': 'Luna',
    },
    {
      'id': 3,
      'title': 'Control de peso',
      'time': '11:00 AM',
      'clinic': 'Clínica Veterinaria San Miguel',
      'date': {
        'day': 28,
        'month': 6,
        'year': 2023,
      },
      'icon': 'monitor_weight',
      'color': '#35B4DD',
      'petName': 'Rocky',
    },
  ];

  // Métodos auxiliares para trabajar con los datos JSON
  Map<int, List<Map<String, dynamic>>> getAppointmentsForMonth(DateTime month) {
    Map<int, List<Map<String, dynamic>>> monthAppointments = {};

    for (var appointment in appointmentsData) {
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
      ),
      body: Column(
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
        onPressed: () {},
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
  final currentMonthAppointments = getAppointmentsForMonth(currentMonth);
  final hasAppointment = isCurrentMonth && currentMonthAppointments.containsKey(day);
  final isToday = isCurrentMonth &&
      day == DateTime.now().day &&
      currentMonth.month == DateTime.now().month &&
      currentMonth.year == DateTime.now().year;

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
                  ? const Color(0xFF8158B7)
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
  final currentMonthAppointments = getAppointmentsForMonth(currentMonth);
  List<Widget> appointmentWidgets = [];

  // Convertir las citas del mes actual a widgets
  currentMonthAppointments.forEach((day, dayAppointments) {
    for (var appointment in dayAppointments) {
      appointmentWidgets.add(_buildAppointmentCard(appointment: appointment));
    }
  });

  // Ordenar por día
  appointmentWidgets.sort((a, b) {
    // Esta es una ordenación básica, podrías mejorarla si necesitas más precisión
    return 0;
  });

  if (appointmentWidgets.isEmpty) {
    return const Center(
      child: Text(
        'No tienes citas programadas este mes',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    children: appointmentWidgets,
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
                appointment['clinic'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (appointment['petName'] != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Para: ${appointment['petName']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: appointmentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
}
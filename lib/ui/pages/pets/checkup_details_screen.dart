import 'package:flutter/material.dart';
import '../../../application/delete_checkup_use_case.dart';
import '../../../domain/entities/checkup.dart';
import 'checkup_form_screen.dart';
import '../../../main.dart';

class CheckupDetailsScreen extends StatefulWidget {
  final Checkup checkup;
  final int petId;

  const CheckupDetailsScreen({
    super.key,
    required this.checkup,
    required this.petId,
  });

  @override
  State<CheckupDetailsScreen> createState() => _CheckupDetailsScreenState();
}

class _CheckupDetailsScreenState extends State<CheckupDetailsScreen> {
  late DateTime currentMonth;
  late DateTime checkupDate;
  late Checkup currentCheckup; // Variable para mantener el checkup actualizado
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentCheckup = widget.checkup; // Inicializar con el checkup original
    // Parse the checkup date (assuming format is YYYY-MM-DD)
    checkupDate = DateTime.parse(currentCheckup.date);
    currentMonth = DateTime(checkupDate.year, checkupDate.month);
  }

  // Método para actualizar el checkup y refrescar la UI
  void _updateCheckup(Checkup updatedCheckup) {
    setState(() {
      currentCheckup = updatedCheckup;
      // Actualizar también la fecha del checkup para el calendario
      checkupDate = DateTime.parse(updatedCheckup.date);
      // Si cambió el mes, actualizar también currentMonth
      if (checkupDate.year != currentMonth.year || checkupDate.month != currentMonth.month) {
        currentMonth = DateTime(checkupDate.year, checkupDate.month);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Revisión'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - usando currentCheckup en lugar de widget.checkup
            Text(
              currentCheckup.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            // Description - usando currentCheckup en lugar de widget.checkup
            Text(
              currentCheckup.description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF34495E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Date label
            const Text(
              'Fecha:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            // Calendar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCalendarHeader(),
                  _buildCalendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editCheckup,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteCheckup,
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
    List<Widget> weeks = [];

    // Primer día del mes
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    // Último día del mes
    DateTime lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Día de la semana del primer día (0 = Sunday, 1 = Monday, etc.)
    // Ajustamos para que Monday = 0
    int firstDayWeekday = (firstDay.weekday - 1) % 7;

    int totalDays = lastDay.day;
    int weeksCount = ((firstDayWeekday + totalDays) / 7).ceil();

    for (int week = 0; week < weeksCount; week++) {
      List<Widget> dayWidgets = [];

      for (int day = 0; day < 7; day++) {
        int dayNumber = week * 7 + day + 1 - firstDayWeekday;

        Widget dayWidget;
        if (dayNumber <= 0 || dayNumber > totalDays) {
          // Día vacío
          dayWidget = const SizedBox();
        } else {
          // Verificar si es el día del checkup
          bool isCheckupDay = currentMonth.year == checkupDate.year &&
              currentMonth.month == checkupDate.month &&
              dayNumber == checkupDate.day;

          dayWidget = Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCheckupDay ? const Color(0xFF3498DB) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  color: isCheckupDay ? Colors.white : const Color(0xFF2C3E50),
                  fontWeight: isCheckupDay ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        dayWidgets.add(Expanded(
          child: Center(child: dayWidget),
        ));
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: dayWidgets),
        ),
      );
    }

    return weeks;
  }

  Future<void> _editCheckup() async {
    print("NAVEGANDO A EDITAR CHECKUP ID: ${currentCheckup.id}");

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckupFormScreen(
          petId: widget.petId,
          isEditMode: true,
          checkup: currentCheckup, // Usar currentCheckup en lugar de widget.checkup
        ),
      ),
    );

    print("RESULTADO DE EDICIÓN: $result");

    // Si el resultado es un Checkup actualizado, actualizar la UI
    if (result != null && result is Checkup) {
      print("ACTUALIZANDO CHECKUP CON NUEVOS DATOS");
      _updateCheckup(result);

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revisión actualizada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    // Si el resultado es true (cambios realizados pero no se retornó el checkup)
    else if (result == true) {
      print("CAMBIOS DETECTADOS - CERRANDO PANTALLA DE DETALLES");
      // En este caso, cerrar la pantalla de detalles para que se actualice la lista
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _deleteCheckup() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta revisión? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    // Si el usuario canceló, no hacer nada
    if (confirmed != true) {
      print("ELIMINACIÓN CANCELADA");
      return;
    }

    print("INICIANDO ELIMINACIÓN DEL CHECKUP ID: ${currentCheckup.id}");

    setState(() {
      _isLoading = true;
    });

    try {
      final deleteCheckupUseCase = getIt<DeleteCheckupUseCase>();
      final success = await deleteCheckupUseCase.deleteCheckup(currentCheckup.id);

      print("RESULTADO DE ELIMINACIÓN: $success");

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revisión eliminada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          print("NAVEGANDO DE VUELTA CON RESULTADO TRUE");
          // Importante: Retornar true para indicar que hubo cambios
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la revisión'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting checkup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
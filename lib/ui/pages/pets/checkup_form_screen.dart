import 'package:flutter/material.dart';
import '../../../application/delete_checkup_use_case.dart';
import '../../../application/update_checkup_use_case.dart';
import '../../../domain/entities/checkup.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../main.dart';

class CheckupFormScreen extends StatefulWidget {
  final bool isEditMode;
  final Checkup? checkup;
  final int petId;

  const CheckupFormScreen({
    super.key,
    this.isEditMode = false,
    this.checkup,
    required this.petId,
  });

  @override
  State<CheckupFormScreen> createState() => _CheckupFormScreenState();
}

class _CheckupFormScreenState extends State<CheckupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.checkup != null) {
      _initializeEditData();
    }
  }

  void _initializeEditData() {
    final checkup = widget.checkup!;
    _titleController.text = checkup.title;
    _descriptionController.text = checkup.description;

    // Parse date and set controllers
    try {
      _selectedDate = DateTime.parse(checkup.date);
      _dateController.text = _formatDateForDisplay(_selectedDate!);
    } catch (e) {
      print('Error parsing date: $e');
    }
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  Future<void> _updateCheckup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateCheckupUseCase = getIt<UpdateCheckupUseCase>();

      final updatedCheckup = Checkup(
        id: widget.checkup!.id,
        petId: widget.petId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      );

      final success = await updateCheckupUseCase.updateCheckup(updatedCheckup);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revision actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar la revision'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating checkup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
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

  Future<void> _deleteCheckup() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta revision? Esta acción no se puede deshacer.'),
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

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final deleteCheckupUseCase = getIt<DeleteCheckupUseCase>();
      final success = await deleteCheckupUseCase.deleteCheckup(widget.checkup!.id);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revision eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la revision'),
              backgroundColor: Colors.red,
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Editar Revision Medica' : 'Nueva Revision Medica',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
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
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Ej: Vacunación, Revisión general, etc.',
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

              // Date field
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

              // Description field
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Agrega detalles sobre la revision...',
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
              const SizedBox(height: 32),

              // Action buttons
              if (widget.isEditMode) ...[
                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateCheckup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Actualizar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Delete button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _deleteCheckup,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.red[600],
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Create button (for new checkups)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      // TODO: Implement create checkup functionality
                      // You'll need to add CreateCheckupUseCase
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Agregar Revision Medica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
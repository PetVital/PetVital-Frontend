import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../../application/change_password_use_case.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isLoading = false;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        _isLoading = true;
      });

      final changePasswordUseCase = getIt<ChangePasswordUseCase>();

      try {
        final success = await changePasswordUseCase.changePassword(
          newPasswordController.text,
        );

        if (mounted) {
          if (success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña actualizada correctamente'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar la contraseña'),
                backgroundColor: Color(0xFFE53E3E),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocurrió un error inesperado'),
              backgroundColor: Color(0xFFE53E3E),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
            color: const Color(0xff212121),
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de la nueva contraseña
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  hintText: 'Nueva contraseña',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                style: const TextStyle(
                  color: Color(0xFF585858),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: const Color(0xFF585858),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la nueva contraseña.';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo para repetir la nueva contraseña
              TextFormField(
                controller: repeatPasswordController,
                decoration: InputDecoration(
                  hintText: 'Repetir nueva contraseña',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                style: const TextStyle(
                  color: Color(0xFF585858),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: const Color(0xFF585858),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, repite la nueva contraseña.';
                  }
                  if (value != newPasswordController.text) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Botón de iniciar sesión
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
                    onPressed: _isLoading ? null : _handleChangePassword,
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
                      'Actualizar contraseña',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                    color: Color(0xff585858),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }
}
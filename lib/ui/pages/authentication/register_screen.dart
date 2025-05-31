import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../main.dart';
import 'login_screen.dart';
import '../pet_form_screen.dart';
import '../../../application/register_use_case.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _scrollController = ScrollController();
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      try {
        setState(() {
          _isLoading=true;
        });

        final registerUseCase = getIt<RegisterUseCase>();

        final success = await registerUseCase.register(
          _nameController.text,
          _lastNameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (success) {
          //await Future.delayed(Duration(seconds: 3)); // Espera 3 segundos antes de continuar
          setState(() {
            _isLoading=false;
          });
          // Registro exitoso → redirige a la siguiente pantalla
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PetFormScreen(isFirstTime: true),
            ),
          );
        } else {
          setState(() {
            _isLoading=false;
          });
          // Registro fallido → muestra error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro fallido. Intenta nuevamente')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Título principal
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo
                  const Text(
                    'Regístrate para comenzar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campo de nombres
                  const Text(
                    'Nombres',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      } else if (value.trim().length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$").hasMatch(value)) {
                        return 'El nombre solo puede contener letras';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Tu nombre',
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
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo de apellidos
                  const Text(
                    'Apellidos',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese sus apellidos';
                      } else if (value.trim().length < 2) {
                        return 'Los apellidos deben tener al menos 2 caracteres';
                      } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$").hasMatch(value)) {
                        return 'Los apellidos solo pueden contener letras';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Tus apellidos',
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
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de correo electrónico
                  const Text(
                    'Correo electrónico',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo electrónico';
                      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                        return 'Por favor ingrese un correo electrónico válido';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'ejemplo@correo.com',
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
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      } else if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                        return 'La contraseña debe contener al menos una mayúscula, una minúscula y un número';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Mínimo 8 caracteres',
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
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de confirmar contraseña
                  const Text(
                    'Confirmar contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirme su contraseña';
                      } else if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Confirma tu contraseña',
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
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Casilla de aceptar términos
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF8C52FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Acepto los ',
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: 'Términos de servicio',
                                style: TextStyle(color: Colors.blue[400]),
                              ),
                              const TextSpan(
                                text: ' y la ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: 'Política de privacidad',
                                style: TextStyle(color: Colors.blue[400]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botón de crear cuenta
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _acceptTerms
                            ? const LinearGradient(
                          colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                            : LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[300]!],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_acceptTerms) ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading ? Color(0xFFE5E5E5)  : Colors.transparent, // Se vuelve gris si está cargando
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          disabledBackgroundColor: Color(0xFFE5E5E5) , // También aseguramos que el color deshabilitado sea gris
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
                            : Text( // Eliminamos "const" aquí
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 20,
                            color: _acceptTerms ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Separador "O continúa con"
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'O registrate con',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Opciones de inicio de sesión con redes sociales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón de Google
                      _socialLoginButton(
                        onPressed: () {},
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                      ),

                      // Botón de Facebook
                      _socialLoginButton(
                        onPressed: () {},
                        icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                      ),

                      // Botón de Apple
                      _socialLoginButton(
                        onPressed: () {},
                        icon: const FaIcon(FontAwesomeIcons.apple),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Inicia sesion',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'authentication/login_screen.dart';
import 'authentication/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 200,
                height: 200,
                child: Center(
                  child: Image.asset(
                    'assets/images/petvital_logo.png',
                    width: 400,
                    height: 400,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Título de bienvenida
              const Text(
                '¡Bienvenido a\nPetVital!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo
              const Text(
                'La aplicación que cuida la\nsalud y bienestar de tus\nmascotas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Botón de iniciar sesión
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)], // Degradado púrpura a azul
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Para que el botón no sobreescriba el gradiente
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Texto en blanco para contraste
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón de crear cuenta
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Texto de términos y condiciones
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Al continuar, aceptas nuestros\n',
                  style: const TextStyle(color: Colors.grey,fontSize: 15 ),
                  children: [
                    TextSpan(
                      text: 'Términos de servicio',
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                    const TextSpan(
                      text: ' y ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: 'Política de\nprivacidad',
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
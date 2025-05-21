import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo
              const Text(
                'La aplicación que cuida la\nsalud y bienestar de tus\nmascotas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Botón de iniciar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C52FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Iniciar sesión'),
                ),
              ),

              const SizedBox(height: 16),

              // Botón de crear cuenta
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Crear cuenta'),
                ),
              ),

              const SizedBox(height: 24),

              // Texto de términos y condiciones
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Al continuar, aceptas nuestros\n',
                  style: const TextStyle(color: Colors.grey),
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
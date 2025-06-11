// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../ui/pages/main/main_page.dart';
import '../../ui/pages/home/home_screen.dart';
import '../../ui/pages/appointments/appointments_screen.dart';
import '../../ui/pages/chat/chat_screen.dart';
import '../../ui/pages/pets/pets_screen.dart';
import '../../ui/pages/welcome_screen.dart';
import '../../ui/pages/authentication/login_screen.dart';
import '../../ui/pages/authentication/register_screen.dart';

class AppRoutes {
  // Rutas de autenticación
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';

  static const String main = '/main';
  static const String home = '/home';
  static const String appointments = '/appointments';
  static const String chat = '/chat';
  static const String pets = '/pets';

  static Map<String, WidgetBuilder> get routes => {
    // Rutas de autenticación
    welcome: (_) => const WelcomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),

    // Rutas de la aplicación principal
    home: (_) => const HomeScreen(),
    appointments: (_) => const AppointmentsScreen(),
    chat: (_) => const ChatScreen(),
    pets: (_) => const PetsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == main) {
      final args = settings.arguments as Map<String, dynamic>?;

      final initialIndex = args?['initialIndex'] ?? 0;

      return MaterialPageRoute(
        builder: (_) => MainPage(initialIndex: initialIndex),
      );
    }

    return null; // para otras rutas no manejadas dinámicamente
  }
}
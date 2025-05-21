// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../ui/pages/main/main_page.dart';
import '../../ui/pages/home/home_page.dart';
import '../../ui/pages/appointments/appointments_page.dart';
import '../../ui/pages/chat/chat_page.dart';
import '../../ui/pages/pets/pets_page.dart';
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
    main: (_) => const MainPage(),
    home: (_) => const HomePage(),
    appointments: (_) => const AppointmentsPage(),
    chat: (_) => const ChatPage(),
    pets: (_) => const PetsPage(),
  };
}
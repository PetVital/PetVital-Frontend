// lib/ui/pages/main/main_page.dart
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../appointments/appointments_screen.dart';
import '../chat/chat_screen.dart';
import '../pets/pets_screen.dart';
import 'widgets/bottom_navigation_widget.dart';
import '../../../domain/entities/pet.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  final Pet? pet;

  const MainPage({Key? key, this.initialIndex = 0, this.pet}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;
  Pet? _pet;
  bool _isFirstNavigation = true; // ✅ Flag para controlar la primera navegación

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pet = widget.pet; // ✅ Inicializar con el pet que viene del widget (si viene)
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // ✅ Si navegamos al chat desde el navbar (no es la primera vez)
      // y no estamos ya en el chat, limpiar el pet
      if (index == 2 && !_isFirstNavigation) {
        _pet = null;
      }

      // ✅ Marcar que ya no es la primera navegación
      if (_isFirstNavigation) {
        _isFirstNavigation = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = const HomeScreen();
        break;
      case 1:
        currentPage = const AppointmentsScreen();
        break;
      case 2:
        currentPage = ChatScreen(pet: _pet);
        break;
      case 3:
        currentPage = const PetsScreen();
        break;
      default:
        currentPage = const HomeScreen();
    }

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
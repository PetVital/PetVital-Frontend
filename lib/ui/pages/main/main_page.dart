// lib/ui/pages/main/main_page.dart
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../appointments/appointments_screen.dart';
import '../chat/chat_screen.dart';
import '../pets/pets_screen.dart';
import 'widgets/bottom_navigation_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const AppointmentsScreen(),
    const ChatScreen(),
    const PetsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
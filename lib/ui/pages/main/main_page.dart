// lib/ui/pages/main/main_page.dart
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../appointments/appointments_page.dart';
import '../chat/chat_page.dart';
import '../pets/pets_page.dart';
import 'widgets/bottom_navigation_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AppointmentsPage(),
    const ChatPage(),
    const PetsPage(),
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
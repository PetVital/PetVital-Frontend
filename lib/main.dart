import 'package:flutter/material.dart';
import 'ui/pages/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetVital',
      debugShowCheckedModeBanner: false, // Esto quita el banner de "Debug"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8C52FF),
          primary: const Color(0xFF8C52FF),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'ui/pages/welcome_screen.dart';
import 'core/routes/app_routes.dart';
import 'application/register_use_case.dart';
import 'data/repositories/user_repositoy_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'data/api/user_api.dart';

final getIt = GetIt.instance;

void main() {
  // Data Layer - APIs
  getIt.registerLazySingleton<UserApi>(() => UserApi());

  // Data Layer - Repositories
  getIt.registerLazySingleton<UserRepository>(() =>
      UserRepositoryImpl(getIt<UserApi>())
  );

  // Domain Layer (use cases)
  getIt.registerLazySingleton<RegisterUseCase>(() =>
      RegisterUseCase(getIt<UserRepository>())
  );

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
      initialRoute: AppRoutes.welcome,  // Cambiado a la ruta de bienvenida
      routes: AppRoutes.routes,
    );
  }
}
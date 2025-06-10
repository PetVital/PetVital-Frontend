import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//use cases
import 'application/add_pet_use_case.dart';
import 'application/get_home_data_use_case.dart';
import 'application/login_use_case.dart';
import 'application/register_use_case.dart';
import 'application/get_user_pets_use_case.dart';
import 'application/add_appointment_use_case.dart';
import 'application/get_user_appointmets_use_case.dart';
//repository impl
import 'data/repositories/user_repositoy_impl.dart';
import 'data/repositories/pet_repository_impl.dart';
import 'data/repositories/home_repository_impl.dart';
import 'data/repositories/appointment_repository_impl.dart';
//repository
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/pet_repository.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/repositories/appointment_repository.dart';
//api
import 'data/api/user_api.dart';
import 'data/api/pet_api.dart';
import 'data/api/home_api.dart';
import 'data/api/appointment_api.dart';

final getIt = GetIt.instance;

void main() {
  // Data Layer - APIs
  getIt.registerLazySingleton<UserApi>(() => UserApi());
  getIt.registerLazySingleton<PetApi>(() => PetApi());
  getIt.registerLazySingleton<HomeApi>(() => HomeApi());
  getIt.registerLazySingleton<AppointmentApi>(() => AppointmentApi());

  // Data Layer - Repositories
  getIt.registerLazySingleton<UserRepository>(() =>
      UserRepositoryImpl(getIt<UserApi>())
  );
  getIt.registerLazySingleton<PetRepository>(() =>
      PetRepositoryImpl(getIt<PetApi>())
  );
  getIt.registerLazySingleton<HomeRepository>(() =>
      HomeRepositoryImpl(getIt<HomeApi>())
  );
  getIt.registerLazySingleton<AppointmentRepository>(() =>
      AppointmentRepositoryImpl(getIt<AppointmentApi>())
  );

  // Domain Layer (use cases)
  getIt.registerLazySingleton<RegisterUseCase>(() =>
      RegisterUseCase(getIt<UserRepository>())
  );
  getIt.registerLazySingleton<LoginUseCase>(() =>
      LoginUseCase(getIt<UserRepository>())
  );
  getIt.registerLazySingleton<AddPetUseCase>(() =>
      AddPetUseCase(getIt<PetRepository>())
  );
  getIt.registerLazySingleton<GetHomeDataUseCase>(() =>
      GetHomeDataUseCase(getIt<HomeRepository>())
  );
  getIt.registerLazySingleton<GetUserPetsUseCase>(() =>
      GetUserPetsUseCase(getIt<PetRepository>())
  );
  getIt.registerLazySingleton<AddAppointmentUseCase>(() =>
      AddAppointmentUseCase(getIt<AppointmentRepository>())
  );
  getIt.registerLazySingleton<GetUserAppointmentsUseCase>(() =>
      GetUserAppointmentsUseCase(getIt<AppointmentRepository>())
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      initialRoute: AppRoutes.welcome,  // Cambiado a la ruta de bienvenida
      routes: AppRoutes.routes,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:petvital/application/delete_checkup_use_case.dart';
import 'package:petvital/application/get_pet_checkups_use_case.dart';
import 'package:petvital/data/repositories/message_repository_impl.dart';
import 'package:petvital/ui/pages/main/main_page.dart';
import 'core/routes/app_routes.dart';
import 'domain/entities/pet.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Este archivo se genera automáticamente
import 'package:firebase_messaging/firebase_messaging.dart';
//use cases
import 'application/add_pet_use_case.dart';
import 'application/get_home_data_use_case.dart';
import 'application/login_use_case.dart';
import 'application/register_use_case.dart';
import 'application/get_user_pets_use_case.dart';
import 'application/add_appointment_use_case.dart';
import 'application/get_user_appointmets_use_case.dart';
import 'application/send_message_use_case.dart';
import 'application/get_pet_appointments_use_case.dart';
import 'application/delete_pet_use_case.dart';
import 'application/update_pet_use_case.dart';
import 'application/get_appointment_detail_use_case.dart';
import 'application/delete_appointment_use_case.dart';
import 'application/add_checkup_use_case.dart';
import 'application/update_checkup_use_case.dart';
//repository impl
import 'data/repositories/user_repositoy_impl.dart';
import 'data/repositories/pet_repository_impl.dart';
import 'data/repositories/home_repository_impl.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/checkup_repository_impl.dart';
import 'data/repositories/local_storage_service.dart';
//repository
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/pet_repository.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/repositories/appointment_repository.dart';
import 'domain/repositories/message_repository.dart';
import 'domain/repositories/checkup_repository.dart';
//api
import 'data/api/user_api.dart';
import 'data/api/pet_api.dart';
import 'data/api/home_api.dart';
import 'data/api/appointment_api.dart';
import 'data/api/message_api.dart';
import 'data/api/checkup_api.dart';


import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

final getIt = GetIt.instance;

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  // Data Layer - APIs
  getIt.registerLazySingleton<UserApi>(() => UserApi());
  getIt.registerLazySingleton<PetApi>(() => PetApi());
  getIt.registerLazySingleton<HomeApi>(() => HomeApi());
  getIt.registerLazySingleton<AppointmentApi>(() => AppointmentApi());
  getIt.registerLazySingleton<MessageApi>(() => MessageApi());
  getIt.registerLazySingleton<CheckupApi>(() => CheckupApi());

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
  getIt.registerLazySingleton<MessageRepository>(() =>
      MessageRepositoryImpl(getIt<MessageApi>())
  );
  getIt.registerLazySingleton<CheckupRepository>(() =>
      CheckupRepositoryImpl(getIt<CheckupApi>())
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
  getIt.registerLazySingleton<SendMessageUseCase>(() =>
      SendMessageUseCase(getIt<MessageRepository>())
  );
  getIt.registerLazySingleton<GetPetAppointmentsUseCase>(() =>
      GetPetAppointmentsUseCase(getIt<AppointmentRepository>())
  );
  getIt.registerLazySingleton<DeletePetUseCase>(() =>
      DeletePetUseCase(getIt<PetRepository>())
  );
  getIt.registerLazySingleton<UpdatePetUseCase>(() =>
      UpdatePetUseCase(getIt<PetRepository>())
  );
  getIt.registerLazySingleton<GetAppointmentDetailUseCase>(() =>
      GetAppointmentDetailUseCase(getIt<AppointmentRepository>())
  );
  getIt.registerLazySingleton<DeleteAppointmentUseCase>(() =>
      DeleteAppointmentUseCase(getIt<AppointmentRepository>())
  );
  getIt.registerLazySingleton<AddCheckupUseCase>(() =>
      AddCheckupUseCase(getIt<CheckupRepository>())
  );
  getIt.registerLazySingleton<GetPetCheckupsUseCase>(() =>
      GetPetCheckupsUseCase(getIt<CheckupRepository>())
  );
  getIt.registerLazySingleton<DeleteCheckupUseCase>(() =>
      DeleteCheckupUseCase(getIt<CheckupRepository>())
  );
  getIt.registerLazySingleton<UpdateCheckupUseCase>(() =>
      UpdateCheckupUseCase(getIt<CheckupRepository>())
  );

  // Inicializar timezone
  tz.initializeTimeZones();

  // Configurar OneSignal
  await configureOneSignal();

  runApp(const MyApp());
}

Future<void> configureOneSignal() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Reemplaza con tu App ID de OneSignal
  OneSignal.initialize("64b1091b-6756-4760-97f2-b280b458dc49");

  // Solicitar permisos de notificación
  OneSignal.Notifications.requestPermission(true);

  // Manejar cuando se abre la app desde una notificación
  OneSignal.Notifications.addClickListener((event) {
    print('Notificación clickeada: ${event.notification.additionalData}');

    // Aquí puedes navegar a una pantalla específica
    // Por ejemplo, si tienes datos en additionalData
    if (event.notification.additionalData != null) {
      String? route = event.notification.additionalData!['route'];
      if (route != null) {
        // Navegar a la ruta específica
        navigatorKey.currentState?.pushNamed(route);
      }
    }
  });

  // Manejar notificaciones recibidas cuando la app está abierta
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print('Notificación recibida en foreground: ${event.notification.title}');
    // Mostrar la notificación incluso cuando la app está abierta
    event.preventDefault();
    event.notification.display();
  });
}

// GlobalKey para navegación
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Mensaje recibido en background: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetVital',
      navigatorKey: navigatorKey,
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
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.main) {
            final args = settings.arguments as Map<String, dynamic>?;
            final index = args?['initialIndex'] ?? 0;
            final pet = args?['pet'] as Pet?;
            return MaterialPageRoute(
              builder: (_) => MainPage(initialIndex: index, pet: pet),
            );
          }
          return null;
        }
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/pet_controller.dart';
import 'controllers/medical_record_controller.dart';
import 'controllers/appointment_controller.dart';
import 'controllers/smart_analyzer_controller.dart';
import 'controllers/vet_controller.dart';
import 'views/auth/auth_wrapper.dart';
import 'utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'views/owner/visits/visit_detail_view.dart';
import 'models/appointment_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Optional: background handling logic
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => PetController()),
        ChangeNotifierProvider(create: (_) => MedicalRecordController()),
        ChangeNotifierProvider(create: (_) => AppointmentController()),
        ChangeNotifierProvider(create: (_) => SmartAnalyzerController()),
        ChangeNotifierProvider(create: (_) => VetController()),
      ],
      child: const PawHealthApp(),
    ),
  );
}

class PawHealthApp extends StatelessWidget {
  const PawHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawHealth',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.lightSurface,
        ),
        scaffoldBackgroundColor: AppColors.lightSurface,
        textTheme: GoogleFonts.figtreeTextTheme(),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/appointment-details': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final id = args?['id'] as String?;
          final ctrl = context.watch<AppointmentController>();
          final allAppointments = [...ctrl.upcomingVisits, ...ctrl.pastVisits];
          
          Appointment? appointment;
          try {
            appointment = allAppointments.firstWhere((a) => a.appointmentId == id);
          } catch (_) {}

          if (appointment == null) {
            // Ideally fetch from backend, but showing empty/loading for now
            return const Scaffold(
              body: Center(child: Text("Appointment not found or loading...")),
            );
          }

          return VisitDetailView(appointment: appointment);
        },
      },
    );
  }
}

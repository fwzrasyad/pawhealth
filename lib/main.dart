import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    // state management config
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
      // AuthWrapper decides whether to show Onboarding, OwnerDashboard, or
      // VetHomeView based on the current auth state from AuthController.
      home: const AuthWrapper(),
    );
  }
}

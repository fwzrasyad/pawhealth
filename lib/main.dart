import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/pet_controller.dart';
import 'controllers/medical_record_controller.dart';
import 'controllers/appointment_controller.dart';
import 'controllers/smart_analyzer_controller.dart';
import 'controllers/vet_controller.dart';
import 'views/auth/auth_wrapper.dart'; // ← Centralized auth+routing widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    // App-wide State Management configuration
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8A2BE2)),
        useMaterial3: true,
      ),
      // AuthWrapper decides whether to show Onboarding, OwnerDashboard, or
      // VetHomeView based on the current auth state from AuthController.
      home: const AuthWrapper(),
    );
  }
}

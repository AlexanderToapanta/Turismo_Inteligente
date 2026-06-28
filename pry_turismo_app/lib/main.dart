import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'viewmodels/turismo_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/resena_viewmodel.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/welcome_view.dart';
import 'theme/tema_turismo.dart';

void main() async {
  // Asegura que los servicios de Flutter (GPS, Sensores) estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('es', null);
  
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveemos el ViewModel a toda la aplicación
        ChangeNotifierProvider(create: (_) => TurismoViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ResenaViewModel()),
      ],
      child: MaterialApp(
        title: 'Turismo Local App',
        debugShowCheckedModeBanner: false,
        theme: TemaPersona5.temaClaro,
        home: hasSeenOnboarding ? const AuthChecker() : const WelcomeView(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.usuario != null) {
          return const HomeView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}

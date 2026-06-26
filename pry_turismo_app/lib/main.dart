import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/turismo_viewmodel.dart';
import 'views/home_view.dart';
import 'theme/tema_turismo.dart';

void main() {
  // Asegura que los servicios de Flutter (GPS, Sensores) estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveemos el ViewModel a toda la aplicación
        ChangeNotifierProvider(create: (_) => TurismoViewModel()),
      ],
      child: MaterialApp(
        title: 'Turismo Local App',
        debugShowCheckedModeBanner: false,
        theme: TemaPersona5.temaClaro,
        home: const HomeView(),
      ),
    );
  }
}

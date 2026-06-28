import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Para navegar a AuthChecker

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  Future<void> _acceptPermissions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthChecker()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas y Permisos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuestra Política de Datos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Para ofrecerte la mejor experiencia y funcionalidad, nuestra aplicación requiere acceso a ciertos datos y funciones de tu dispositivo. Al continuar, aceptas el uso de:',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.camera_alt, color: Colors.redAccent, size: 36),
                title: const Text('Cámara y Galería', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text('Se utilizará para poder tomar fotos de los lugares y subir imágenes en tus reseñas.'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
                title: const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text('Se requiere para mostrarte los lugares turísticos cercanos y ayudarte a llegar a ellos.'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _acceptPermissions(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aceptar y Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

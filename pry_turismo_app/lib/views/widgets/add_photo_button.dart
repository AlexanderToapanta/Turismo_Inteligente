import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../take_photo_view.dart';

class AddPhotoButton extends StatelessWidget {
  const AddPhotoButton({Key? key}) : super(key: key);

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515), // Tema oscuro / Surface
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFE60012)), // primaryColor
                title: const Text('Subir desde el dispositivo', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  
                  // Pedir permiso explícito para acceder a los archivos/fotos
                  Map<Permission, PermissionStatus> statuses = await [
                    Permission.storage,
                    Permission.photos,
                  ].request();

                  // En Android 13+ (READ_MEDIA_IMAGES) se valida photos, en anteriores storage.
                  // También consideramos isLimited para iOS.
                  if (statuses[Permission.storage]!.isGranted || 
                      statuses[Permission.photos]!.isGranted ||
                      statuses[Permission.photos]!.isLimited) {
                    try {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        print('Imagen seleccionada: ${image.path}');
                      }
                    } catch (e) {
                      debugPrint('Error al abrir la galería: $e');
                    }
                  } else {
                    debugPrint('Permiso de acceso a archivos denegado');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE60012)),
                title: const Text('Tomar una foto', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  
                  // Pedir permisos de cámara
                  if (await Permission.camera.request().isGranted) {
                    try {
                      final cameras = await availableCameras();
                      if (context.mounted) {
                        final photoPath = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TakePhotoView(cameras: cameras),
                          ),
                        );

                        if (photoPath != null) {
                          print('Foto tomada: $photoPath');
                        }
                      }
                    } catch (e) {
                      print('Error al iniciar la cámara: $e');
                    }
                  } else {
                    debugPrint('Permiso de cámara denegado');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showOptions(context),
      backgroundColor: const Color(0xFFE60012), // primaryColor
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 32),
    );
  }
}

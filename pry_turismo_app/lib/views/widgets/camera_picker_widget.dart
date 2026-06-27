import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../take_photo_view.dart';
import '../../theme/tema_turismo.dart';

/// Botón de cámara con diseño visual de recuadro fotográfico.
/// [onImageSelected] devuelve la ruta del archivo cuando el usuario
/// elige o toma una foto. Si ya hay una imagen seleccionada,
/// muestra la vista previa; de lo contrario muestra el placeholder.
class CameraPickerWidget extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String> onImageSelected;

  const CameraPickerWidget({
    super.key,
    this.imagePath,
    required this.onImageSelected,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TemaPersona5.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: TemaPersona5.primaryColor),
                title: const Text('Galería',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickFromGallery(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: TemaPersona5.primaryColor),
                title: const Text('Tomar foto',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _takePhoto(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
    ].request();

    if (statuses[Permission.storage]!.isGranted ||
        statuses[Permission.photos]!.isGranted ||
        statuses[Permission.photos]!.isLimited) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          onImageSelected(image.path);
        }
      } catch (e) {
        debugPrint('Error al abrir la galería: $e');
      }
    } else {
      debugPrint('Permiso de acceso a fotos denegado');
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    if (await Permission.camera.request().isGranted) {
      try {
        final cameras = await availableCameras();
        if (context.mounted) {
          final photoPath = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => TakePhotoView(cameras: cameras),
            ),
          );
          if (photoPath != null) {
            onImageSelected(photoPath);
          }
        }
      } catch (e) {
        debugPrint('Error al iniciar la cámara: $e');
      }
    } else {
      debugPrint('Permiso de cámara denegado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: TemaPersona5.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: imagePath != null
                ? TemaPersona5.primaryColor
                : TemaPersona5.dividerColor,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Vista previa de la imagen seleccionada
                  Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _placeholder(context),
                  ),
                  // Botón para cambiar la foto (esquina inferior derecha)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TemaPersona5.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícono de cámara
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TemaPersona5.primaryColor.withValues(alpha: 0.1),
            border: Border.all(
              color: TemaPersona5.primaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.camera_alt,
            size: 36,
            color: TemaPersona5.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Toca para agregar una foto',
          style: TextStyle(
            color: TemaPersona5.textSecondary.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cámara o galería',
          style: TextStyle(
            color: TemaPersona5.textSecondary.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

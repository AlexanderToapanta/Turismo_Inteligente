import 'package:flutter/material.dart';
import '../../theme/tema_turismo.dart';

class ImagenPlaceholderWidget extends StatelessWidget {
  const ImagenPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TemaPersona5.surfaceColor,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: TemaPersona5.textSecondary,
        ),
      ),
    );
  }
}

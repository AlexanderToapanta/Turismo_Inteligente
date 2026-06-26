import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tema_turismo.dart';
import 'widgets/add_photo_button.dart';

class CamaraView extends StatelessWidget {
  const CamaraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaPersona5.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: TemaPersona5.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Sube y comparte tus fotos favoritas',
                textAlign: TextAlign.center,
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: TemaPersona5.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'de los lugares turísticos que visitaste.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TemaPersona5.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              const AddPhotoButton(),
            ],
          ),
        ),
      ),
    );
  }
}

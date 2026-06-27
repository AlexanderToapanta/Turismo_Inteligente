import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'mapa_view.dart';
import 'lista_sitios_view.dart';
import 'rutas_view.dart';
import 'camara_view.dart';
import 'resenas_view.dart';
import 'crear_resena_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Índice 2 = Mapa (centro)
  int _indiceActual = 2;

  // Orden: Reseñas | Agregar | MAPA (centro) | Fotos | Rutas
  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.list_alt_rounded,  label: 'Reseñas',  isCenter: false),
    _NavItem(icon: Icons.add_rounded,        label: 'Agregar',  isCenter: false),
    _NavItem(icon: Icons.map_rounded,        label: 'Mapa',     isCenter: true),
    _NavItem(icon: Icons.camera_alt_rounded, label: 'Fotos',    isCenter: false),
    _NavItem(icon: Icons.navigation_rounded, label: 'Rutas',    isCenter: false),
  ];

  // Vistas reales sólo para los índices que tienen vista asignada
  Widget _buildView(int index) {
    switch (index) {
      case 2:
        return const MapaView();
      case 3:
        return const CamaraView();
      case 4:
        return const RutasView();
      case 1:
        return const ListaSitiosView();
      case 0:
        return const ResenasView();
      default:
        return _PlaceholderView(label: _items[index].label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // 0xFFE60012
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Turismo Local',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white24,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 20, color: Colors.white)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Cerrar sesión',
                    onPressed: () {
                      authViewModel.signOut();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
      extendBody: true, // Para que el body vaya detrás de la notch
      body: _buildView(_indiceActual),
      floatingActionButton: _indiceActual == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CrearResenaView(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _CustomNavBar(
        selectedIndex: _indiceActual,
        items: _items,
        primaryColor: primaryColor,
        onTap: (i) => setState(() => _indiceActual = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Modelo de ítem de navegación
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  final bool isCenter;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCenter,
  });
}

// ─────────────────────────────────────────────
//  NavBar personalizado con "bump" central
// ─────────────────────────────────────────────
class _CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final Color primaryColor;
  final ValueChanged<int> onTap;

  const _CustomNavBar({
    required this.selectedIndex,
    required this.items,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 64;
    const double bumpRadius = 34;
    const double bottomMargin = 0;
    const double topMargin = 24;
    const double totalHeight = barHeight + bottomMargin + topMargin;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double sideWidth = (screenWidth / 2) - 45; // No lateral margin

    return SizedBox(
      height: totalHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ── Barra con notch ──
          CustomPaint(
            size: Size(screenWidth, totalHeight),
            painter: _FloatingNotchPainter(
              notchRadius: bumpRadius + 6,
              barColor: const Color(0xFF111111),
              shadowColor: Colors.black,
              topMargin: topMargin,
              bottomMargin: bottomMargin,
            ),
          ),

          // ── Ítems izquierdos ──
          Positioned(
            bottom: bottomMargin,
            left: 0,
            width: sideWidth,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 2; i++)
                  _NavButton(
                    item: items[i],
                    selected: selectedIndex == i,
                    primaryColor: primaryColor,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),

          // ── Ítems derechos ──
          Positioned(
            bottom: bottomMargin,
            right: 0,
            width: sideWidth,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 3; i < 5; i++)
                  _NavButton(
                    item: items[i],
                    selected: selectedIndex == i,
                    primaryColor: primaryColor,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),

          // ── Botón central BUMP ──
          Positioned(
            bottom: bottomMargin + 10, // Ubicación balanceada
            child: GestureDetector(
              onTap: () => onTap(2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: bumpRadius * 2,
                height: bumpRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIndex == 2
                      ? primaryColor
                      : const Color(0xFF1A1A1A),
                  border: Border.all(
                    color: selectedIndex == 2
                        ? primaryColor.withValues(alpha: 0.3)
                        : const Color(0xFF333333),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (selectedIndex == 2 ? primaryColor : Colors.black)
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  items[2].icon,
                  color: selectedIndex == 2
                      ? Colors.white
                      : const Color(0xFF666666),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Botón individual de navegación
// ─────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo al seleccionar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? primaryColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: selected
                    ? Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                item.icon,
                color: selected ? primaryColor : const Color(0xFF666666),
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? primaryColor : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Painter: barra con notch curvo en el centro
// ─────────────────────────────────────────────
class _FloatingNotchPainter extends CustomPainter {
  final double notchRadius;
  final Color barColor;
  final Color shadowColor;
  final double topMargin;
  final double bottomMargin;

  const _FloatingNotchPainter({
    required this.notchRadius,
    required this.barColor,
    required this.shadowColor,
    required this.topMargin,
    required this.bottomMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final double cx = size.width / 2;
    final double topY = topMargin;
    final double bottomY = size.height - bottomMargin;
    const double left = 0.0;
    final double right = size.width;
    const double cornerRadius = 24.0;

    final double gap = notchRadius + 4;
    const double curveOffset = 18.0;

    final path = Path()
      // Esquina superior izquierda
      ..moveTo(left + cornerRadius, topY)
      // Borde superior izquierdo
      ..lineTo(cx - gap - curveOffset, topY)
      // Notch (curva central)
      ..quadraticBezierTo(
          cx - gap, topY, cx - gap, topY - notchRadius / 4)
      ..arcToPoint(
        Offset(cx + gap, topY - notchRadius / 4),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(
          cx + gap, topY, cx + gap + curveOffset, topY)
      // Borde superior derecho
      ..lineTo(right - cornerRadius, topY)
      // Esquina superior derecha
      ..quadraticBezierTo(right, topY, right, topY + cornerRadius)
      // Borde lateral derecho
      ..lineTo(right, bottomY)
      // Borde inferior
      ..lineTo(left, bottomY)
      // Borde lateral izquierdo
      ..lineTo(left, topY + cornerRadius)
      // Cerrar en esquina superior izquierda
      ..quadraticBezierTo(left, topY, left + cornerRadius, topY)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Borde sutil
    final borderPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  Placeholder para pestañas sin vista aún
// ─────────────────────────────────────────────
class _PlaceholderView extends StatelessWidget {
  final String label;
  const _PlaceholderView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 56,
            color: const Color(0xFFE60012).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              color: Colors.white54,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

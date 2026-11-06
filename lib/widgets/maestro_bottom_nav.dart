import 'package:flutter/material.dart';

/// Barra de navegación inferior de Maestro con 3 opciones:
/// To do (check), Profile (persona en el centro) y Materias (libro).
///
/// - [selectedIndex]: qué pestaña está activa (0, 1 o 2).
/// - [onItemTapped]: función que avisa a la pantalla principal
///   cuando el usuario pulsa un botón. Así este Widget no guarda
///   el estado, solo muestra la barra.
///
/// Los 3 botones se comportan igual: solo el seleccionado se
/// encierra en un círculo blanco, invierte sus colores y
/// muestra su texto. Al cambiar de pestaña, todo se anima.
class MaestroBottomNav extends StatelessWidget {
  const MaestroBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF241340),
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              icon: Icons.check,
              label: 'To do',
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavButton(
              icon: Icons.person,
              label: 'Profile',
              isSelected: selectedIndex == 1,
              isCenter: true,
              onTap: () => onItemTapped(1),
            ),
            _NavButton(
              icon: Icons.menu_book,
              label: 'Materias',
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón individual de la barra. Es privado (_NavButton) porque
/// solo se usa dentro de este archivo.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCenter = false,
  });

  /// Ícono a mostrar (check, persona o libro).
  final IconData icon;

  /// Texto debajo del ícono. Solo se ve cuando está seleccionado.
  final String label;

  /// Si esta pestaña es la activa, se encierra e invierte colores.
  final bool isSelected;

  /// Qué hacer cuando se pulsa.
  final VoidCallback onTap;

  /// Si es el botón central de Profile, mantiene una elevación base.
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    // Cuánto debe subir el ícono SOLO visualmente:
    // - Lateral sin seleccionar: 0px (en su sitio)
    // - Lateral seleccionado: sube 10px
    // - Central sin seleccionar: base de 8px (siempre más alto)
    // - Central seleccionado: 8px base + 6px extra = 14px
    //
    // En vez de Padding (que sí ocupa espacio y movía la barra),
    // usamos la propiedad transform de AnimatedContainer: mueve el
    // dibujo sin cambiar el tamaño que ocupa en el layout.
    // La barra nunca crece.
    final double targetElevation = isCenter
        ? (isSelected ? 14 : 8)
        : (isSelected ? 10 : 0);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AnimatedContainer anima el cambio de color y forma:
          // transparente cuando no está seleccionado,
          // círculo blanco cuando sí lo está. El ícono se invierte
          // de blanco a oscuro al mismo tiempo.
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 52,
            height: 52,
            // transform mueve SOLO el dibujo (efecto Transform.translate),
            // sin ocupar espacio extra: la barra no crece ni se mueve.
            // Matrix4.translationValues(x, y, z): y negativo = arriba.
            transform: Matrix4.translationValues(0, -targetElevation, 0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF1A0F2E) : Colors.white54,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          // AnimatedOpacity anima la aparición del texto:
          // opaco (visible) si está seleccionado,
          // transparente (invisible) si no lo está.
          // El texto sigue existiendo en el árbol, por eso
          // la altura de la barra no salta al cambiar.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: isSelected ? 1.0 : 0.0,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

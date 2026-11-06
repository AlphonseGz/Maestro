import 'package:flutter/material.dart';

/// Barra de navegación inferior de Maestro con 3 opciones:
/// To do (check), Profile (persona en el centro) y Materias (libro).
///
/// - [selectedIndex]: qué pestaña está activa (0, 1 o 2).
/// - [onItemTapped]: función que avisa a la pantalla principal
///   cuando el usuario pulsa un botón. Así este Widget no guarda
///   el estado, solo muestra la barra.
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

  /// Texto debajo del ícono.
  final String label;

  /// Si esta pestaña es la activa, se muestra más brillante.
  final bool isSelected;

  /// Qué hacer cuando se pulsa.
  final VoidCallback onTap;

  /// Si es el botón central de Profile, se dibuja elevado e invertido.
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    // El botón del centro va ligeramente más alto que los demás.
    final double verticalOffset = isCenter ? -14 : 0;

    return InkWell(
      onTap: onTap,
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCenter)
              // Círculo con colores invertidos: fondo blanco, persona oscura.
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1A0F2E),
                  size: 32,
                ),
              )
            else
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white54,
                size: 28,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

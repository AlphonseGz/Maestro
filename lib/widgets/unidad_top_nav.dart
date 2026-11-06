import 'package:flutter/material.dart';

import '../models/unidad.dart';

/// NavBar superior horizontal de unidades.
///
/// Cada unidad creada aparece como un ítem en una fila deslizable
/// horizontalmente. Solo el seleccionado se encierra en una pastilla
/// blanca. La animación es de 200ms (menos exagerada que la barra
/// inferior, que usa 300ms y elevación).
///
/// - [unidades]: lista de unidades de la materia actual.
/// - [selectedIndex]: qué unidad está activa.
/// - [onItemTapped]: avisa a la pantalla al pulsar un ítem.
class UnidadTopNav extends StatelessWidget {
  const UnidadTopNav({
    super.key,
    required this.unidades,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final List<Unidad> unidades;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            for (int index = 0; index < unidades.length; index++)
              _UnidadItem(
                unidad: unidades[index],
                isSelected: index == selectedIndex,
                onTap: () => onItemTapped(index),
              ),
          ],
        ),
      ),
    );
  }
}

/// Ítem individual de una unidad dentro de la NavBar superior.
class _UnidadItem extends StatelessWidget {
  const _UnidadItem({
    required this.unidad,
    required this.isSelected,
    required this.onTap,
  });

  final Unidad unidad;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Unidad.iconoPorClave(unidad.iconoClave),
              color: isSelected ? const Color(0xFF1A0F2E) : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 6),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              opacity: isSelected ? 1.0 : 0.6,
              child: Text(
                unidad.nombre,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1A0F2E) : Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

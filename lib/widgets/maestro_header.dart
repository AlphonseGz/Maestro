import 'package:flutter/material.dart';

/// Encabezado reutilizable de Maestro.
///
/// En vez de escribir el encabezado en cada pantalla (duplicar código),
/// lo guardamos en un solo Widget y lo reutilizamos donde haga falta.
/// A la derecha, en pequeño y arriba, va el crédito del autor.
class MaestroHeader extends StatelessWidget {
  const MaestroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFF1A0F2E),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.music_note, color: Color(0xFF8B3DFF), size: 32),
          SizedBox(width: 10),
          Text(
            'MAESTRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          Spacer(),
          // Crédito pequeño en la esquina superior derecha.
          Text(
            'Made By\nAlphonse Gz',
            textAlign: TextAlign.end,
            style: TextStyle(color: Colors.white54, fontSize: 9, height: 1.3),
          ),
        ],
      ),
    );
  }
}

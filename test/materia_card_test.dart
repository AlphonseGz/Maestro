// Prueba de la tarjeta de materia.
//
// Comprueba que MateriaCard muestra el título, el contador 0/0
// y el porcentaje 0%, sin depender de guardar datos en el teléfono.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestro/models/materia.dart';
import 'package:maestro/widgets/materia_card.dart';

void main() {
  testWidgets('MateriaCard muestra título y 0/0 Tasks', (
    WidgetTester tester,
  ) async {
    final Materia materiaPrueba = Materia(
      titulo: 'Mathematics',
      colorValue: const Color(0xFF8B3DFF).toARGB32(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MateriaCard(materia: materiaPrueba)),
      ),
    );

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('0/0 Tasks'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });

  test('Materia convierte a JSON y vuelve igual', () {
    final Materia original = Materia(
      titulo: 'English',
      colorValue: const Color(0xFF2D5BFF).toARGB32(),
      fotoPath: '/tmp/foto.png',
    );

    final Materia restaurada = Materia.fromJson(original.toJson());

    expect(restaurada.titulo, 'English');
    expect(restaurada.colorValue, original.colorValue);
    expect(restaurada.fotoPath, '/tmp/foto.png');
    expect(restaurada.progreso, 0);
  });
}

// Pruebas de tareas: JSON, formato de fecha y tarjeta.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestro/models/tarea.dart';
import 'package:maestro/models/unidad.dart';
import 'package:maestro/utils/fecha_formato.dart';
import 'package:maestro/widgets/tarea_card.dart';

void main() {
  test('Tarea se guarda y se restaura en JSON con su fecha', () {
    final Tarea original = Tarea(
      titulo: 'Quiz 8',
      descripcion: 'Estudiar capítulo 4',
      fechaLimite: DateTime(2026, 11, 13, 22, 30),
    );

    final Tarea restaurada = Tarea.fromJson(original.toJson());

    expect(restaurada.titulo, 'Quiz 8');
    expect(restaurada.descripcion, 'Estudiar capítulo 4');
    expect(restaurada.fechaLimite, DateTime(2026, 11, 13, 22, 30));
    expect(restaurada.completada, false);
  });

  test('Unidad guarda sus tareas en JSON', () {
    final Unidad unidad = Unidad(nombre: 'Unidad 1');
    unidad.tareas.add(
      Tarea(
        titulo: 'Tarea 1',
        descripcion: 'Descripción',
        fechaLimite: DateTime(2026, 11, 12, 22),
      ),
    );

    final Unidad restaurada = Unidad.fromJson(unidad.toJson());

    expect(restaurada.tareas.length, 1);
    expect(restaurada.tareas[0].titulo, 'Tarea 1');
  });

  test('Formato de fecha en español', () {
    expect(
      formatearFechaLarga(DateTime(2026, 11, 12)),
      'Jueves, 12 de noviembre de 2026',
    );
    expect(formatearHora(DateTime(2026, 11, 12, 22, 5)), '22:05');
  });

  testWidgets('TareaCard muestra título, descripción y materia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TareaCard(
            tarea: Tarea(
              titulo: '25 de Mayo',
              descripcion: 'Assignment is due',
              fechaLimite: DateTime(2026, 11, 12, 22),
            ),
            colorMateria: const Color(0xFF8B3DFF),
            nombreMateria: 'FÍSICA ELÉCTRICA',
            iconoUnidad: Icons.menu_book,
          ),
        ),
      ),
    );

    expect(find.text('25 de Mayo'), findsOneWidget);
    expect(find.text('Assignment is due'), findsOneWidget);
    expect(find.text('FÍSICA ELÉCTRICA'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);
  });
}

// Pruebas de tareas: JSON, formato de fecha y tarjeta.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestro/models/materia.dart';
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

  test('Añadir una tarea no modifica la fecha de las demás (bug)', () {
    // Escenario del bug: lista compartida, se edita la fecha de una
    // tarea y luego se añade otra tarea a la MISMA lista.
    // La primera tarea debe conservar su fecha nueva.
    final Materia materia = Materia(
      titulo: 'Física',
      colorValue: const Color(0xFF8B3DFF).toARGB32(),
    );
    final Unidad unidad = Unidad(nombre: 'Unidad 1');
    materia.unidades.add(unidad);
    unidad.tareas.add(
      Tarea(
        titulo: 'Quiz 8',
        descripcion: 'Desc',
        fechaLimite: DateTime(2026, 11, 12, 22),
      ),
    );

    // Editar la fecha (como hace To do) sobre la lista compartida.
    final Tarea editada = unidad.tareas[0].copyWith(
      fechaLimite: DateTime(2026, 12, 1, 10),
    );
    unidad.tareas[0] = editada;

    // Añadir una tarea nueva (como hace Detalle) sobre la misma lista.
    unidad.tareas.add(
      Tarea(
        titulo: 'Nueva',
        descripcion: 'Desc 2',
        fechaLimite: DateTime(2026, 11, 20, 9),
      ),
    );

    // La fecha editada debe seguir intacta.
    expect(unidad.tareas[0].fechaLimite, DateTime(2026, 12, 1, 10));
    expect(unidad.tareas[1].titulo, 'Nueva');

    // Y tras guardar/cargar en JSON, ambas fechas se conservan.
    final Materia restaurada = Materia.fromJson(materia.toJson());
    expect(
      restaurada.unidades[0].tareas[0].fechaLimite,
      DateTime(2026, 12, 1, 10),
    );
    expect(
      restaurada.unidades[0].tareas[1].fechaLimite,
      DateTime(2026, 11, 20, 9),
    );
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

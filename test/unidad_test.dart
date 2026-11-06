// Pruebas de unidades y de la NavBar superior.
//
// Comprueban que una materia guarda sus unidades en JSON,
// que el ícono por defecto es el punto y que la NavBar
// superior avisa al pulsar otra unidad.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestro/models/materia.dart';
import 'package:maestro/models/unidad.dart';
import 'package:maestro/widgets/unidad_top_nav.dart';

void main() {
  test('Unidad por defecto usa el ícono punto', () {
    final Unidad unidad = Unidad(nombre: 'Unidad 1');

    expect(unidad.iconoClave, 'punto');
    expect(Unidad.iconoPorClave('punto'), Icons.circle);
    expect(Unidad.poolIconos.length, 8);
  });

  test('Materia guarda y restaura sus unidades en JSON', () {
    final Materia original = Materia(
      titulo: 'Mathematics',
      colorValue: const Color(0xFF8B3DFF).toARGB32(),
    );
    original.unidades.add(Unidad(nombre: 'Álgebra', iconoClave: 'calculadora'));
    original.unidades.add(Unidad(nombre: 'Geometría'));

    final Materia restaurada = Materia.fromJson(original.toJson());

    expect(restaurada.unidades.length, 2);
    expect(restaurada.unidades[0].nombre, 'Álgebra');
    expect(restaurada.unidades[0].iconoClave, 'calculadora');
    expect(restaurada.unidades[1].iconoClave, 'punto');
    expect(restaurada.id, original.id);
  });

  testWidgets('UnidadTopNav avisa al pulsar otra unidad', (
    WidgetTester tester,
  ) async {
    int? indicePulsado;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnidadTopNav(
            unidades: [
              Unidad(nombre: 'Unidad 1'),
              Unidad(nombre: 'Unidad 2', iconoClave: 'estrella'),
            ],
            selectedIndex: 0,
            onItemTapped: (index) => indicePulsado = index,
          ),
        ),
      ),
    );

    expect(find.text('Unidad 1'), findsOneWidget);
    expect(find.text('Unidad 2'), findsOneWidget);

    await tester.tap(find.text('Unidad 2'));
    await tester.pump();

    expect(indicePulsado, 1);
  });
}

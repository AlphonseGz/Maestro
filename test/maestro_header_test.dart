// Prueba del encabezado principal de Maestro.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestro/widgets/maestro_header.dart';

void main() {
  testWidgets('Header muestra MAESTRO y el crédito del autor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaestroHeader())),
    );

    expect(find.text('MAESTRO'), findsOneWidget);
    expect(find.text('Made By\nAlphonse Gz'), findsOneWidget);
  });
}

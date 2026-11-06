// Prueba básica de Maestro.
//
// Comprueba que la app arranca y muestra la pantalla temporal
// de bienvenida con el mensaje Bienvenido "Concertante".

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maestro/main.dart';

void main() {
  testWidgets('Muestra la Splash con Bienvenido Concertante', (
    WidgetTester tester,
  ) async {
    // shared_preferences necesita un valor inicial simulado en pruebas,
    // porque MateriasScreen lo lee al iniciar (IndexedStack lo construye).
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaestroApp());

    // La Splash debe mostrar el mensaje de bienvenida y el logo.
    expect(find.text('Bienvenido "Concertante"'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Avanzamos el tiempo 4 segundos para que la Splash
    // navegue a la pantalla principal.
    await tester.pump(const Duration(seconds: 4));
    // Esperamos la animación de cambio de pantalla (300ms aprox.)
    // y la carga de Materias, sin usar pumpAndSettle porque el
    // indicador de carga anima sin fin y haría timeout.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 100));

    // Ya no debe verse el mensaje temporal de bienvenida.
    expect(find.text('Bienvenido "Concertante"'), findsNothing);
    // En la pantalla principal sí aparece MAESTRO en el encabezado.
    expect(find.text('MAESTRO'), findsOneWidget);
    // La barra inferior debe mostrar las 3 opciones.
    // "To do" aparece dos veces: título de la página inicial y botón de la barra.
    expect(find.text('To do'), findsWidgets);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Materias'), findsOneWidget);
  });
}

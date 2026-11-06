// Prueba básica de Maestro.
//
// Comprueba que la app arranca y muestra la pantalla temporal
// de bienvenida con el mensaje Bienvenido "Concertante".

import 'package:flutter_test/flutter_test.dart';

import 'package:maestro/main.dart';

void main() {
  testWidgets('Muestra la Splash con Bienvenido Concertante',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaestroApp());

    // La Splash debe mostrar el mensaje de bienvenida.
    expect(find.text('Bienvenido "Concertante"'), findsOneWidget);
    expect(find.text('MAESTRO'), findsOneWidget);

    // Avanzamos el tiempo 2 segundos para que la Splash
    // navegue a la pantalla principal.
    await tester.pump(const Duration(seconds: 2));
    // Esperamos a que termine la animación de cambio de pantalla.
    await tester.pumpAndSettle();

    // Ya no debe verse el mensaje temporal de bienvenida.
    expect(find.text('Bienvenido "Concertante"'), findsNothing);
    // La barra inferior debe mostrar las 3 opciones.
    // "To do" aparece dos veces: título de la página inicial y botón de la barra.
    expect(find.text('To do'), findsWidgets);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Materias'), findsOneWidget);
  });
}

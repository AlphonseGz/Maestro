# Maestro

Aplicación Flutter de gestión de materias y tareas académicas, con tema oscuro (fondo `#1A0F2E`, acento morado `#8B3DFF` / azul `#2D5BFF`, Material 3) y notificaciones locales de vencimiento.

> Estado actual: app funcional en desarrollo — Materias, Unidades y To do están implementados; la pantalla **Profile** es aún un placeholder («Pantalla en construcción»).

## Funcionalidades

- **Splash screen**: muestra el logo (`assets/images/maestro_logo.png`) y el mensaje `Bienvenido "Concertante"` durante 4 segundos, y luego navega a la pantalla principal.
- **Materias** (`Subjects`): crear, editar y eliminar materias con título, color personalizado (`flutter_colorpicker`) y foto opcional de galería (`image_picker`).
- **Unidades**: cada materia se divide en unidades con nombre e ícono (pool de 8 íconos académicos). Crear, editar y eliminar desde la pantalla de detalle.
- **Tareas**: crear, editar, eliminar, completar y ver detalle de tareas dentro de cada unidad, con título, descripción, fecha/hora límite y opción de auto-borrado.
- **To do list**: vista agregada de todas las tareas de todas las materias/unidades, ordenadas por fecha límite y agrupadas por día.
- **Persistencia local**: todo se guarda en el teléfono con `shared_preferences` como JSON (sin backend).
- **Notificaciones locales** (`flutter_local_notifications` + `timezone` / `flutter_timezone`): canal «Tareas de Maestro» en Android. Por cada tarea pendiente se programan avisos: inicio del día de vencimiento, 1 hora antes y a la hora límite. Incluye botón de notificación de prueba en To do para diagnóstico, y auto-delete de tareas 2 minutos después de su hora límite al abrir la app.

## Stack

- Dart SDK `^3.13.7` (`pubspec.yaml`), Flutter / Material 3
- Dependencias principales: `cupertino_icons`, `flutter_colorpicker`, `image_picker`, `shared_preferences`, `flutter_local_notifications`, `timezone`, `flutter_timezone`
- Dev: `flutter_lints` (`analysis_options.yaml` → `package:flutter_lints/flutter.yaml`, excluye carpetas de plataforma y `build/`)

## Estructura

```
lib/
  main.dart                      # Punto de entrada: inicializa notificaciones y arranca MaestroApp
  models/
    materia.dart                 # Materia (id, título, color, foto, unidades)
    unidad.dart                  # Unidad (nombre, iconoClave, tareas) + pool de íconos
    tarea.dart                   # Tarea (id, título, descripción, fechaLimite, completada, autoDelete)
  screens/
    splash_screen.dart           # Bienvenida temporal (4 s)
    home_screen.dart             # Dueña única de la lista de materias; IndexedStack con 3 pestañas
    todo_screen.dart             # To do: todas las tareas agrupadas por día
    materias_screen.dart         # Lista de materias + formulario crear/editar
    materia_detalle_screen.dart  # Detalle de materia: unidades y tareas
  services/
    materia_storage.dart         # Carga/guarda materias en shared_preferences (JSON)
    notificacion_service.dart    # Inicialización, programación y sincronización de notificaciones
  widgets/
    maestro_header.dart          # Encabezado "MAESTRO"
    maestro_bottom_nav.dart      # Barra inferior: To do / Profile / Materias
    materia_card.dart            # Tarjeta de materia
    tarea_card.dart              # Tarjeta de tarea
    unidad_top_nav.dart          # Nav superior de unidades en el detalle
    formulario_tarea_dialog.dart # Formulario crear/editar tarea
    detalle_tarea_dialog.dart    # Detalle de tarea
  utils/
    fecha_formato.dart           # Utilidades de formato de fechas
assets/images/
  maestro_logo.png               # Logo de la splash
  maestro_icon.png
test/
  widget_test.dart               # Prueba de widget: splash → pantalla principal
```

### Cómo funciona el estado

`HomeScreen` es la única dueña de la lista `List<Materia>`: la carga una vez desde el teléfono y la comparte con `TodoScreen` y `MateriasScreen`. Ambas pantallas avisan con el callback `onChanged` cuando cambian algo; `HomeScreen` guarda en disco, sincroniza las notificaciones (`NotificacionService.sincronizar`) y redibuja. Así se evitan copias desactualizadas entre pantallas.

## Primeros pasos

Requisitos: Flutter y Dart SDK `^3.13.7` instalados.

```bash
flutter pub get      # Instalar dependencias
flutter run          # Ejecutar (hot reload activado por defecto)
```

### Comandos

```bash
flutter pub get                         # Setup
flutter analyze                         # Lint / typecheck
flutter test                            # Todos los tests
flutter test test/widget_test.dart      # Un solo test
flutter run                             # Ejecutar la app
```

El test de widget importa la app como `package:maestro/main.dart`, usa `MaestroApp` directamente y simula `SharedPreferences` con `SharedPreferences.setMockInitialValues({})`. Actualízalo si renombras o mueves `MaestroApp`.

## Notas

- Sin CI, variables de entorno ni codegen; las carpetas de plataforma (`android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`) son generadas — no editarlas salvo petición expresa.
- Sin backend: los datos viven solo en el dispositivo. Las notificaciones programadas se re-sincronizan en cada guardado.
- Proyectos relacionados: consultar `AGENTS.md` para las convenciones del repo.

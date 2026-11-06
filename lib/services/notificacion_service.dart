import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/materia.dart';
import '../models/tarea.dart';
import '../utils/fecha_formato.dart';

/// Servicio de notificaciones locales para las tareas.
///
/// Programa 3 notificaciones por tarea (si están en el futuro
/// y la tarea no está completada):
/// 1. Cuando llega el día de vencimiento (excepto si se creó
///    el mismo día que vence).
/// 2. Cuando queda 1 hora para vencer.
/// 3. Cuando llega la hora de la tarea (esta va ligada al auto-delete:
///    al abrir la app 2 minutos después, la tarea se borra sola).
///
/// Los IDs de notificación se derivan del id de la tarea, así
/// reprogramar la misma tarea reemplaza la anterior (no duplica).
class NotificacionService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _inicializado = false;

  /// Inicializa el plugin y la zona horaria del teléfono.
  /// Se llama una vez desde main() antes de arrancar la app.
  static Future<void> inicializar() async {
    if (_inicializado) return;
    try {
      tzdata.initializeTimeZones();
      final TimezoneInfo zona = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zona.identifier));
    } catch (_) {
      // Si no se puede obtener la zona (ej. en pruebas), se usa UTC.
      tzdata.initializeTimeZones();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _plugin.initialize(settings: initializationSettings);

    // Creamos el canal de notificaciones de tareas en Android.
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'tareas',
        'Tareas de Maestro',
        description: 'Avisos de vencimiento de tareas',
        importance: Importance.high,
      ),
    );
    _inicializado = true;
  }

  /// Pide el permiso de notificaciones (Android 13+).
  /// Se llama al crear la primera tarea; si ya se dio, no molesta.
  static Future<void> solicitarPermiso() async {
    if (!_inicializado) return;
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  static NotificationDetails get _detalles => const NotificationDetails(
    android: AndroidNotificationDetails(
      'tareas',
      'Tareas de Maestro',
      channelDescription: 'Avisos de vencimiento de tareas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  );

  /// Cancela todas las notificaciones programadas.
  static Future<void> cancelarTodas() async {
    if (!_inicializado) return;
    await _plugin.cancelAll();
  }

  /// Programa las 3 notificaciones de una tarea.
  static Future<void> programarTarea(Tarea tarea, String nombreMateria) async {
    if (!_inicializado || tarea.completada) return;
    final int baseId = tarea.id.hashCode & 0x7fffffff;
    final DateTime ahora = DateTime.now();

    // 1) Cuando llega el día (00:00 del día de vencimiento),
    // excepto si se creó el mismo día que vence.
    final bool mismoDiaCreacion =
        soloDia(tarea.creadaEn) == soloDia(tarea.fechaLimite);
    if (!mismoDiaCreacion) {
      final DateTime inicioDelDia = DateTime(
        tarea.fechaLimite.year,
        tarea.fechaLimite.month,
        tarea.fechaLimite.day,
      );
      if (inicioDelDia.isAfter(ahora)) {
        await _programar(
          baseId,
          inicioDelDia,
          'Hoy vence: ${tarea.titulo}',
          'La tarea de $nombreMateria vence hoy.',
        );
      }
    }

    // 2) Cuando queda 1 hora para vencer.
    final DateTime unaHoraAntes = tarea.fechaLimite.subtract(
      const Duration(hours: 1),
    );
    if (unaHoraAntes.isAfter(ahora)) {
      await _programar(
        baseId + 1,
        unaHoraAntes,
        'Queda 1 hora: ${tarea.titulo}',
        'La tarea de $nombreMateria vence en 1 hora.',
      );
    }

    // 3) Cuando llega la hora de la tarea.
    if (tarea.fechaLimite.isAfter(ahora)) {
      await _programar(
        baseId + 2,
        tarea.fechaLimite,
        'Vence ahora: ${tarea.titulo}',
        'La tarea de $nombreMateria acaba de vencer.',
      );
    }
  }

  static Future<void> _programar(
    int id,
    DateTime cuando,
    String titulo,
    String cuerpo,
  ) async {
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(cuando, tz.local),
      notificationDetails: _detalles,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: titulo,
      body: cuerpo,
    );
  }

  /// Sincroniza todas las notificaciones con la lista actual:
  /// cancela todo y reprograma solo las tareas pendientes.
  /// Se llama en cada guardado desde HomeScreen, así crear,
  /// editar, completar o eliminar tareas actualiza los avisos.
  static Future<void> sincronizar(List<Materia> materias) async {
    if (!_inicializado) return;
    await cancelarTodas();
    for (final Materia materia in materias) {
      for (final unidad in materia.unidades) {
        for (final Tarea tarea in unidad.tareas) {
          await programarTarea(tarea, materia.titulo);
        }
      }
    }
  }
}

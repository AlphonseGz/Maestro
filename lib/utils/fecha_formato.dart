/// Utilidades para formatear fechas en español, sin paquetes extra.
///
/// Guardamos los nombres de días y meses en listas y los elegimos
/// según el número que devuelve DateTime (weekday: 1=lunes...7=domingo).
const List<String> _diasSemana = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const List<String> _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Ej. "jueves, 12 de noviembre de 2026" (con mayúscula inicial).
String formatearFechaLarga(DateTime fecha) {
  final String dia = _diasSemana[fecha.weekday - 1];
  final String diaCapital = dia[0].toUpperCase() + dia.substring(1);
  return '$diaCapital, ${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';
}

/// Ej. "22:00" (siempre con dos dígitos).
String formatearHora(DateTime fecha) {
  final String horas = fecha.hour.toString().padLeft(2, '0');
  final String minutos = fecha.minute.toString().padLeft(2, '0');
  return '$horas:$minutos';
}

/// Solo el día, sin hora, para agrupar tareas por día.
DateTime soloDia(DateTime fecha) {
  return DateTime(fecha.year, fecha.month, fecha.day);
}

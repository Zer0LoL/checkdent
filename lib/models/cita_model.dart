class Cita {
  final String id;
  final DateTime fecha;
  final String horaInicio;
  final String estado; // 'pendiente', 'confirmada', 'cancelada', 'completada'
  final String tratamientoNombre;
  final String? doctorNombre; // Puede venir nulo si el backend no lo envía

  Cita({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.estado,
    required this.tratamientoNombre,
    this.doctorNombre,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] ?? '',
      // El backend envía fecha en formato ISO (2023-10-22T00:00:00.000Z)
      fecha: DateTime.parse(json['fecha']),
      horaInicio: json['horaInicio'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      // Accedemos al objeto anidado 'tratamiento'
      tratamientoNombre: json['tratamiento']?['nombre'] ?? 'Consulta General',
      // Nota: Tu backend actual no está enviando el nombre del doctor en el historial,
      // pero lo dejamos preparado por si lo arreglas luego.
      doctorNombre: json['doctor_nombre'],
    );
  }
}
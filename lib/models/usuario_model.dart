class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? foto;
  final String? telefono;
  final String? direccion;
  final String? especialidad;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.foto,
    this.telefono,
    this.direccion,
    this.especialidad,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? 'Usuario',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'paciente',

      foto: json['foto'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      especialidad: json['especialidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'foto': foto,
      'telefono': telefono,
      'direccion': direccion,
      'especialidad': especialidad,
    };
  }
}
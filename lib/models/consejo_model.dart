class Consejo {
  final String titulo;
  final String descripcion;
  final String autor;

  Consejo({required this.titulo, required this.descripcion, required this.autor});

  factory Consejo.fromJson(Map<String, dynamic> json) {
    return Consejo(
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      autor: json['autor'] ?? '',
    );
  }
}
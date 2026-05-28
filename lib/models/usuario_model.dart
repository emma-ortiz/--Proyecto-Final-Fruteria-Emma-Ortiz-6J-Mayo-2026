class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final String direccion;
  final String? telefono;
  final DateTime? fechaRegistro;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.direccion,
    this.telefono,
    this.fechaRegistro,
  });

  factory Usuario.fromFirestore(Map<String, dynamic> data, String id) {
    return Usuario(
      id: id,
      nombre: data['nombre'] ?? '',
      correo: data['correo'] ?? '',
      rol: data['rol'] ?? 'cliente',
      direccion: data['direccion'] ?? '',
      telefono: data['telefono'],
      fechaRegistro: data['fechaRegistro'] != null
          ? (data['fechaRegistro'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'direccion': direccion,
      'telefono': telefono,
      'fechaRegistro': fechaRegistro,
    };
  }
}

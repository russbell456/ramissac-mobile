class UserModel {
  final int id;
  final String? codigoUnico;
  final String nombre;
  final String apellidos;
  final String? tipoDocumento;
  final String? dni;
  final String? genero;
  final String? fechaNacimiento;
  final String? telefono;
  final String? telefonoSecundario;
  final String? direccion;
  final String email;
  final String? fotoUrl;
  final String? firmaBase64;
  final String? cargo;
  final String? area;
  final String? fechaIngreso;
  final String? fechaBaja;
  final String? estadoLaboral;
  final int? supervisorId;
  final String role;
  final bool activo;
  final String? ultimoAcceso;
  final String? fechaCreacion;
  final String? fechaActualizacion;

  UserModel({
    required this.id,
    this.codigoUnico,
    required this.nombre,
    required this.apellidos,
    this.tipoDocumento,
    this.dni,
    this.genero,
    this.fechaNacimiento,
    this.telefono,
    this.telefonoSecundario,
    this.direccion,
    required this.email,
    this.fotoUrl,
    this.firmaBase64,
    this.cargo,
    this.area,
    this.fechaIngreso,
    this.fechaBaja,
    this.estadoLaboral,
    this.supervisorId,
    required this.role,
    required this.activo,
    this.ultimoAcceso,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      codigoUnico: json['codigo_unico'] as String?,
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      tipoDocumento: json['tipo_documento'] as String?,
      dni: json['dni'] as String?,
      genero: json['genero'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      telefono: json['telefono'] as String?,
      telefonoSecundario: json['telefono_secundario'] as String?,
      direccion: json['direccion'] as String?,
      email: json['email'] as String? ?? '',
      fotoUrl: json['foto_url'] as String?,
      firmaBase64: json['firma_base64'] as String?,
      cargo: json['cargo'] as String?,
      area: json['area'] as String?,
      fechaIngreso: json['fecha_ingreso'] as String?,
      fechaBaja: json['fecha_baja'] as String?,
      estadoLaboral: json['estado_laboral'] as String?,
      supervisorId: json['supervisor_id'] as int?,
      role: (json['role'] ?? json['rol'] ?? 'user') as String,
      activo: json['activo'] as bool? ?? true,
      ultimoAcceso: json['ultimo_acceso'] as String?,
      fechaCreacion: json['fecha_creacion'] as String?,
      fechaActualizacion: json['fecha_actualizacion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_unico': codigoUnico,
      'nombre': nombre,
      'apellidos': apellidos,
      'tipo_documento': tipoDocumento,
      'dni': dni,
      'genero': genero,
      'fecha_nacimiento': fechaNacimiento,
      'telefono': telefono,
      'telefono_secundario': telefonoSecundario,
      'direccion': direccion,
      'email': email,
      'foto_url': fotoUrl,
      'firma_base64': firmaBase64,
      'cargo': cargo,
      'area': area,
      'fecha_ingreso': fechaIngreso,
      'fecha_baja': fechaBaja,
      'estado_laboral': estadoLaboral,
      'supervisor_id': supervisorId,
      'role': role,
      'activo': activo,
      'ultimo_acceso': ultimoAcceso,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }

  UserModel copyWith({
    String? fotoUrl,
    String? firmaBase64,
  }) {
    return UserModel(
      id: id,
      codigoUnico: codigoUnico,
      nombre: nombre,
      apellidos: apellidos,
      tipoDocumento: tipoDocumento,
      dni: dni,
      genero: genero,
      fechaNacimiento: fechaNacimiento,
      telefono: telefono,
      telefonoSecundario: telefonoSecundario,
      direccion: direccion,
      email: email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      firmaBase64: firmaBase64 ?? this.firmaBase64,
      cargo: cargo,
      area: area,
      fechaIngreso: fechaIngreso,
      fechaBaja: fechaBaja,
      estadoLaboral: estadoLaboral,
      supervisorId: supervisorId,
      role: role,
      activo: activo,
      ultimoAcceso: ultimoAcceso,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
    );
  }

  String get nombresCompletos => '$nombre $apellidos';
}

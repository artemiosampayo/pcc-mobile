/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// session_model.dart
///
/// Carpeta:
/// lib/models/
///
/// Descripción:
///
/// Representa la sesión del usuario almacenada localmente.
///
/// ===========================================================

class SessionModel {

  const SessionModel({

    this.id,

    required this.idUsuario,

    required this.usuario,

    required this.nombre,

    required this.rol,

    required this.idEmpleado,

    required this.idUbicacion,

    required this.token,

    required this.fechaLogin,

    this.ultimoSync,

    this.activo = true,

  });

  //------------------------------------------------------------
  // Propiedades
  //------------------------------------------------------------

  final int? id;

  final int idUsuario;

  final String usuario;

  final String nombre;

  final String rol;

  final int idEmpleado;

  final int idUbicacion;

  final String token;

  final String fechaLogin;

  final String? ultimoSync;

  final bool activo;

  //------------------------------------------------------------
  // fromMap
  //------------------------------------------------------------

  factory SessionModel.fromMap(
      Map<String, dynamic> map) {

    return SessionModel(

      id: map['id'],

      idUsuario: map['id_usuario'],

      usuario: map['usuario'],

      nombre: map['nombre'],

      rol: map['rol'],

      idEmpleado: map['id_empleado'],

      idUbicacion: map['id_ubicacion'],

      token: map['token'],

      fechaLogin: map['fecha_login'],

      ultimoSync: map['ultimo_sync'],

      activo: map['activo'] == 1,

    );

  }

  //------------------------------------------------------------
  // toMap
  //------------------------------------------------------------

  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'id_usuario': idUsuario,

      'usuario': usuario,

      'nombre': nombre,

      'rol': rol,

      'id_empleado': idEmpleado,

      'id_ubicacion': idUbicacion,

      'token': token,

      'fecha_login': fechaLogin,

      'ultimo_sync': ultimoSync,

      'activo': activo ? 1 : 0,

    };

  }

  //------------------------------------------------------------
  // copyWith
  //------------------------------------------------------------

  SessionModel copyWith({

    int? id,

    int? idUsuario,

    String? usuario,

    String? nombre,

    String? rol,

    int? idEmpleado,

    int? idUbicacion,

    String? token,

    String? fechaLogin,

    String? ultimoSync,

    bool? activo,

  }) {

    return SessionModel(

      id: id ?? this.id,

      idUsuario: idUsuario ?? this.idUsuario,

      usuario: usuario ?? this.usuario,

      nombre: nombre ?? this.nombre,

      rol: rol ?? this.rol,

      idEmpleado: idEmpleado ?? this.idEmpleado,

      idUbicacion: idUbicacion ?? this.idUbicacion,

      token: token ?? this.token,

      fechaLogin: fechaLogin ?? this.fechaLogin,

      ultimoSync: ultimoSync ?? this.ultimoSync,

      activo: activo ?? this.activo,

    );

  }

}
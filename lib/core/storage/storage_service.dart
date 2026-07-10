import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  //=========================================
  // SESION
  //=========================================

  static Future<void> guardarSesion({

    required String token,

    required String usuario,

    required int idUsuario,

    required int idEmpleado,

    required int idUbicacion,

    required String rol,

  }) async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      'token',
      token,
    );

    await prefs.setString(
      'usuario',
      usuario,
    );
    await prefs.setString(
      'rol',
      rol,
    );
    await prefs.setInt(
      'id_usuario',
      idUsuario,
    );

    await prefs.setInt(
      'id_empleado',
      idEmpleado,
    );

    await prefs.setInt(
      'id_ubicacion',
      idUbicacion,
    );

  }

  //=========================================
  // TOKEN
  //=========================================

  static Future<String?> obtenerToken()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
      'token',
    );

  }

  //=========================================
  // OPERACION
  //=========================================

  static Future<void> guardarOperacion({

    required int idOperacion,

    required int idRuta,

    required int idUbicacion,

  }) async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setInt(
      'id_operacion',
      idOperacion,
    );

    await prefs.setInt(
      'id_ruta',
      idRuta,
    );

    await prefs.setInt(
      'id_ubicacion',
      idUbicacion,
    );

  }

  //=========================================
  // CERRAR SESION
  //=========================================

  static Future<void> cerrarSesion()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();

  }

}
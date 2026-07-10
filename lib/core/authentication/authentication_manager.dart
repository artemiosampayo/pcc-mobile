/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// authentication_manager.dart
///
/// Carpeta:
/// lib/core/authentication/
///
/// ===========================================================

import '../../models/session_model.dart';
import '../../services/local/session_local_service.dart';

class AuthenticationManager {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final AuthenticationManager instance =
      AuthenticationManager._();

  AuthenticationManager._();

  //----------------------------------------------------------
  // Guardar sesión
  //----------------------------------------------------------

  Future<void> guardarSesion(
      SessionModel session) async {

    await SessionLocalService.instance
        .guardarSesion(session);

  }

  //----------------------------------------------------------
  // Obtener sesión
  //----------------------------------------------------------

  Future<SessionModel?> obtenerSesion()
      async {

    return await SessionLocalService.instance
        .obtenerSesion();

  }

  //----------------------------------------------------------
  // ¿Existe sesión?
  //----------------------------------------------------------

  Future<bool> haySesion()
      async {

    return await SessionLocalService.instance
        .haySesion();

  }

  //----------------------------------------------------------
  // Logout
  //----------------------------------------------------------

  Future<void> cerrarSesion()
      async {

    await SessionLocalService.instance
        .eliminarSesion();

  }

  //----------------------------------------------------------
  // Último Sync
  //----------------------------------------------------------

  Future<void> actualizarUltimoSync(
      String fecha) async {

    await SessionLocalService.instance
        .actualizarUltimoSync(fecha);

  }

}
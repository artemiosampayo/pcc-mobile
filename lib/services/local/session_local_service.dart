/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// session_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra la sesión almacenada localmente.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/session_model.dart';

class SessionLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final SessionLocalService instance =
      SessionLocalService._();

  SessionLocalService._();

  //----------------------------------------------------------
  // Obtener BD
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper
        .instance
        .database;

  }

  //----------------------------------------------------------
  // Guardar sesión
  //----------------------------------------------------------

  Future<void> guardarSesion(
      SessionModel session) async {

    final db =
        await _db();

    print("=================================");
    print("SESSION");
    print("Guardar sesión");
    print(session.toMap());

    await db.delete(
      'usuario_sesion',
    );

    await db.insert(

      'usuario_sesion',

      session.toMap(),

      conflictAlgorithm:
          ConflictAlgorithm.replace,

    );

  }

  //----------------------------------------------------------
  // Obtener sesión
  //----------------------------------------------------------

  Future<SessionModel?> obtenerSesion()
      async {

    final db =
        await _db();

    final result =
        await db.query(

      'usuario_sesion',

      limit: 1,

    );

    if(result.isEmpty){

      return null;

    }

    return SessionModel.fromMap(
      result.first,
    );

  }

  //----------------------------------------------------------
  // Existe sesión
  //----------------------------------------------------------

  Future<bool> haySesion() async {

    return
        await obtenerSesion() != null;

  }

  //----------------------------------------------------------
  // Actualizar Token
  //----------------------------------------------------------

  Future<void> actualizarToken(
      String token) async {

    final db =
        await _db();

    await db.update(

      'usuario_sesion',

      {

        'token': token,

      },

    );

  }

  //----------------------------------------------------------
  // Actualizar último sync
  //----------------------------------------------------------

  Future<void> actualizarUltimoSync(
      String fecha) async {

    final db =
        await _db();

    await db.update(

      'usuario_sesion',

      {

        'ultimo_sync': fecha,

      },

    );

  }

  //----------------------------------------------------------
  // Logout
  //----------------------------------------------------------

  Future<void> eliminarSesion()
      async {

    final db =
        await _db();

    await db.delete(
      'usuario_sesion',
    );

  }

}
/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// database_tables.dart
///
/// Carpeta:
/// lib/database/
///
/// Descripción:
///
/// Contiene todas las definiciones SQL utilizadas por SQLite.
///
/// DatabaseHelper NO conoce ninguna tabla.
/// Solamente llama a createAllTables().
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

class DatabaseTables {

  DatabaseTables._();

  //============================================================
  // CREA TODAS LAS TABLAS
  //============================================================

  static Future<void> createAllTables(
    Database db,
  ) async {

    await db.execute(
      createSessionTable(),
    );

    await db.execute(
      createWorkflowTable(),
    );

    await db.execute(
      createEnviosTable(),
    );
    await db.execute(
      createMovimientosTable(),
    );
  }

  //============================================================
  // TABLA
  // ENVIOS
  //============================================================

  static String createEnviosTable() {

    return '''

    CREATE TABLE envios_local(

      id_envio INTEGER PRIMARY KEY,

      numero_guia TEXT,

      pedido TEXT,

      cliente TEXT,

      nombre_cliente TEXT,

      calle TEXT,

      numero TEXT,

      colonia TEXT,

      ciudad TEXT,

      estado TEXT,

      codigo_postal TEXT,

      numero_caja INTEGER,

      total_caja INTEGER,

      estado_envio TEXT,

      escaneada INTEGER DEFAULT 0,

      fecha_escaneo TEXT,

      estatus_local TEXT,

      sincronizado INTEGER DEFAULT 0

    )

    ''';

  }
  

  //============================================================
  // TABLA
  // WORKFLOW
  //============================================================

  static String createWorkflowTable() {

    return '''

    CREATE TABLE workflow_operacion(

      id INTEGER PRIMARY KEY AUTOINCREMENT,

      id_operacion INTEGER,

      id_ruta INTEGER,

      nombre_ruta TEXT,

      id_operador INTEGER,

      nombre_operador TEXT,

      id_ubicacion INTEGER,

      nombre_ubicacion TEXT,

      contenedor TEXT,

      placa TEXT,

      numero_economico TEXT,

      estado_operacion TEXT,

      fecha_inicio TEXT,

      fecha_actualizacion TEXT

    )

    ''';

  }

//============================================================
// TABLA
// SESION
//============================================================

  static String createSessionTable() {

    return '''

    CREATE TABLE usuario_sesion(

      id INTEGER PRIMARY KEY AUTOINCREMENT,

      id_usuario INTEGER,

      usuario TEXT,

      nombre TEXT,

      rol TEXT,

      id_empleado INTEGER,

      id_ubicacion INTEGER,

      token TEXT,

      fecha_login TEXT,

      ultimo_sync TEXT,

      activo INTEGER DEFAULT 1

    )

    ''';

  }
  //============================================================
// TABLA
// MOVIMIENTOS LOCALES
//
// Cola de eventos operativos pendientes de sincronización.
//
// Cada movimiento utiliza uuid_sincronizacion para permitir
// reintentos seguros contra PCC API.
//============================================================

static String createMovimientosTable() {

  return '''

  CREATE TABLE movimientos_local(

    id_local INTEGER PRIMARY KEY AUTOINCREMENT,

    uuid_sincronizacion TEXT NOT NULL UNIQUE,

    id_operacion INTEGER NOT NULL,

    id_envio INTEGER NOT NULL,

    codigo_estado TEXT NOT NULL,

    id_estado INTEGER NOT NULL,

    descripcion TEXT,

    id_ubicacion INTEGER,

    id_empleado INTEGER,

    id_ruta INTEGER,

    latitud REAL,

    longitud REAL,

    dispositivo TEXT,

    fecha_evento TEXT NOT NULL,

    sincronizado INTEGER DEFAULT 0,

    intentos INTEGER DEFAULT 0,

    ultimo_error TEXT,

    UNIQUE(
      id_operacion,
      id_envio,
      codigo_estado
    )

  )

  ''';

}

}
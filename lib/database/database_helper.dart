/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// database_helper.dart
///
/// Carpeta:
/// lib/database/
///
/// Descripción:
///
/// Administra la conexión SQLite de la aplicación.
///
/// No contiene SQL.
/// Toda la definición de tablas vive en:
///
/// database_tables.dart
///
/// ===========================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

class DatabaseHelper {

  //------------------------------------------------------------
  // Singleton
  //------------------------------------------------------------

  static final DatabaseHelper instance =
      DatabaseHelper._();

  DatabaseHelper._();

  //------------------------------------------------------------
  // Constantes
  //------------------------------------------------------------

  static const String databaseName =
      'pcc_mobile.db';

  static const int databaseVersion = 12;

  //------------------------------------------------------------
  // Base de datos
  //------------------------------------------------------------

  Database? _database;

  //------------------------------------------------------------
  // Getter
  //------------------------------------------------------------

  Future<Database> get database async {

    if (_database != null) {

      return _database!;

    }

    _database = await _initDatabase();

    return _database!;

  }

  //------------------------------------------------------------
  // Inicializar SQLite
  //------------------------------------------------------------

  Future<Database> _initDatabase() async {

    final dbPath =
        await getDatabasesPath();

    final path =
        join(
          dbPath,
          databaseName,
        );

    return await openDatabase(

      path,

      version: databaseVersion,

      onCreate: _onCreate,

      //--------------------------------------------------------
      // Migraciones de Base de Datos
      //--------------------------------------------------------

      onUpgrade: _onUpgrade,

    );

  }

  //------------------------------------------------------------
  // Crear Base de Datos
  //------------------------------------------------------------

  Future<void> _onCreate(

      Database db,

      int version,

      ) async {

    await DatabaseTables.createAllTables(
      db,
    );

  }

  //------------------------------------------------------------
  // Futuras migraciones
  //------------------------------------------------------------

  Future<void> _onUpgrade(Database db,int oldVersion,int newVersion,) 
  async {

    //--------------------------------------------------------
    // Migración
    // v5 → v6
    //
    // Agrega soporte local para:
    //
    // • Entregas.
    // • Relación entrega - envíos.
    // • Evidencias.
    //
    // No elimina ni modifica información existente.
    //--------------------------------------------------------

    if (oldVersion < 6) {

      await db.execute(
        DatabaseTables.createEntregasTable(),
      );

      await db.execute(
        DatabaseTables.createEntregaEnviosTable(),
      );

      await db.execute(
        DatabaseTables.createEvidenciasTable(),
      );

    }
    //--------------------------------------------------------
    // Migración
    // v6 → v7
    //
    // Agrega la tabla de referencia entre UUID local e
    // identificador remoto.
    //--------------------------------------------------------

    if (oldVersion < 7) {

      await db.execute(

        DatabaseTables.createMovimientosRemotosTable(),

      );

    }

    //--------------------------------------------------------
    // Migración
    // v7 → v8
    //
    // Agrega catálogo local de devoluciones.
    //--------------------------------------------------------

    if (oldVersion < 8) {

        await db.execute(

            DatabaseTables.createCatalogoDevolucionesTable(),

        );

    }

    //--------------------------------------------------------
    // Migración
    // v8 → v9
    //
    // Agrega soporte para devoluciones locales.
    //--------------------------------------------------------

    if (oldVersion < 9) {

      await db.execute(
        DatabaseTables.createDevolucionesTable(),
      );

      await db.execute(
        DatabaseTables.createDevolucionEnviosTable(),
      );

    }

    if (oldVersion < 10) {

      await db.execute(
          'ALTER TABLE evidencias_local RENAME TO evidencias_local_old');

      await db.execute(
          DatabaseTables.createEvidenciasTable());

      await db.execute('''
          INSERT INTO evidencias_local(
              uuid_evidencia,
              uuid_referencia,
              uuid_movimiento,
              tipo,
              descripcion,
              ruta_archivo,
              nombre_archivo,
              mime_type,
              fecha_creacion,
              sincronizado,
              intentos,
              ultimo_error,
              fecha_sincronizacion
          )
          SELECT
              uuid_evidencia,
              uuid_entrega,
              uuid_movimiento,
              tipo,
              descripcion,
              ruta_archivo,
              nombre_archivo,
              mime_type,
              fecha_creacion,
              sincronizado,
              intentos,
              ultimo_error,
              fecha_sincronizacion
          FROM evidencias_local_old;
      ''');

      await db.execute(
          'DROP TABLE evidencias_local_old');
    }

    //--------------------------------------------------------
    // Migración
    // v10 → v11
    //
    // Agrega uuid_operacion para soportar
    // el Centro de Monitoreo Operativo.
    //--------------------------------------------------------

    if (oldVersion < 11) {

      //------------------------------------------------------
      // movimientos_local
      //------------------------------------------------------

      await db.execute(
        '''
        ALTER TABLE movimientos_local
        ADD COLUMN uuid_operacion TEXT
        '''
      );

      //------------------------------------------------------
      // entregas_local
      //------------------------------------------------------

      await db.execute(
        '''
        ALTER TABLE entregas_local
        ADD COLUMN uuid_operacion TEXT
        '''
      );

      //------------------------------------------------------
      // devoluciones_local
      //------------------------------------------------------

      await db.execute(
        '''
        ALTER TABLE devoluciones_local
        ADD COLUMN uuid_operacion TEXT
        '''
      );

    }

    //--------------------------------------------------------
    // Migración
    // v11 → v12
    //
    // Agrega soporte para:
    //
    // • Motivo de devolución.
    // • Comentarios de devolución.
    //
    // No modifica registros existentes.
    //--------------------------------------------------------

    if (oldVersion < 12) {

      //------------------------------------------------------
      // devoluciones_local
      //------------------------------------------------------

      await db.execute(
        '''
        ALTER TABLE devoluciones_local
        ADD COLUMN id_motivo_devolucion INTEGER
        ''',
      );

      await db.execute(
        '''
        ALTER TABLE devoluciones_local
        ADD COLUMN comentarios TEXT
        ''',
      );

    }

  }

}
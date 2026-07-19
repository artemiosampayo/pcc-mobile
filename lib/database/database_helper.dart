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

  static const int databaseVersion = 7;

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

  }

}
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

  static const int databaseVersion = 5;

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

      // En desarrollo preferimos
      // reinstalar la aplicación.
      //
      // Cuando salga la V1
      // implementaremos migraciones.
      //
      // onUpgrade: _onUpgrade,

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

  Future<void> _onUpgrade(

      Database db,

      int oldVersion,

      int newVersion,

      ) async {

    // Pendiente para V1

  }

}
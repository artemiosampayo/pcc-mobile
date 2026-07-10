/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// workflow_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra la operación activa almacenada
/// localmente en SQLite.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/workflow_model.dart';
import '../../core/enums/operation_state.dart';

class WorkflowLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final WorkflowLocalService instance =
      WorkflowLocalService._();

  WorkflowLocalService._();

  //----------------------------------------------------------
  // Obtener BD
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper.instance.database;

  }

  //----------------------------------------------------------
  // Guardar operación
  //----------------------------------------------------------

  Future<void> guardarOperacion(
      WorkflowModel workflow) async {

    final db = await _db();

    print("====================================");
    print("WORKFLOW");
    print("Guardar operación");
    print(workflow.toMap());

    await db.delete(
      "workflow_operacion",
    );

    await db.insert(

      "workflow_operacion",

      workflow.toMap(),

      conflictAlgorithm:
          ConflictAlgorithm.replace,

    );

  }

  //----------------------------------------------------------
  // Obtener operación
  //----------------------------------------------------------

  Future<WorkflowModel?> obtenerOperacion() async {

    final db = await _db();

    final result =
        await db.query(

      "workflow_operacion",

      limit: 1,

    );

    if(result.isEmpty){

      return null;

    }

    return WorkflowModel.fromMap(
      result.first,
    );

  }

  //----------------------------------------------------------
  // Existe operación
  //----------------------------------------------------------

  Future<bool> hayOperacion() async {

    return
        await obtenerOperacion() != null;

  }

  //----------------------------------------------------------
  // Actualizar estado
  //----------------------------------------------------------

  Future<void> actualizarEstado(
      OperationState estado) async {

    final db =
        await _db();

    await db.update(

      "workflow_operacion",

      {

        "estado_operacion":
            estado.name,

        "fecha_actualizacion":
            DateTime.now()
                .toIso8601String(),

      },

    );

    print("====================================");
    print("WORKFLOW");
    print("Estado actualizado");
    print(estado.name);

  }

  //----------------------------------------------------------
  // Actualizar operación
  //----------------------------------------------------------

  Future<void> actualizarOperacion(
      WorkflowModel workflow) async {

    final db =
        await _db();

    await db.update(

      "workflow_operacion",

      workflow.toMap(),

    );

    print("====================================");
    print("WORKFLOW");
    print("Operación actualizada");

  }

  //----------------------------------------------------------
  // Eliminar operación
  //----------------------------------------------------------

  Future<void> eliminarOperacion()
      async {

    final db =
        await _db();

    await db.delete(
      "workflow_operacion",
    );

    print("====================================");
    print("WORKFLOW");
    print("Operación eliminada");

  }

}
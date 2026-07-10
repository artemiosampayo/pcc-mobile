/// ===========================================================
/// PCC MOBILE
///
/// WorkflowManager
///
/// Responsable de conocer el estado actual de la operación.
///
/// NO realiza navegación.
///
/// NO consume APIs.
///
/// NO modifica SQLite directamente.
///
/// Toda la persistencia será delegada a WorkflowService.
///
/// ===========================================================

import '../../models/workflow_model.dart';
import '../../services/local/workflow_local_service.dart';
import '../enums/operation_state.dart';

class WorkflowManager {

  //---------------------------------------------------------
  // Singleton
  //---------------------------------------------------------

  static final WorkflowManager instance =
      WorkflowManager._();

  WorkflowManager._();

  //---------------------------------------------------------
  // Iniciar operación
  //---------------------------------------------------------

  Future<void> iniciarOperacion(
      WorkflowModel workflow) async {

    print("=================================");
    print("WORKFLOW MANAGER");
    print("Iniciar operación");

    await WorkflowLocalService.instance
        .guardarOperacion(workflow);

  }

  //---------------------------------------------------------
  // Obtener operación
  //---------------------------------------------------------

  Future<WorkflowModel?> obtenerOperacion()
      async {

    return await WorkflowLocalService.instance
        .obtenerOperacion();

  }

  //---------------------------------------------------------
  // Hay operación
  //---------------------------------------------------------

  Future<bool> hayOperacion() async {

    return await WorkflowLocalService.instance
        .hayOperacion();

  }

  //---------------------------------------------------------
  // Estado actual
  //---------------------------------------------------------

  Future<OperationState> estadoActual()
      async {

    final workflow =
        await obtenerOperacion();

    if(workflow == null){

      return OperationState.sinOperacion;

    }

    return workflow.estadoOperacion;

  }

  //---------------------------------------------------------
  // Cambiar estado
  //---------------------------------------------------------

  Future<void> cambiarEstado(
      OperationState estado) async {

    print("=================================");
    print("WORKFLOW MANAGER");
    print("Cambiar estado");
    print(estado.name);

    await WorkflowLocalService.instance
        .actualizarEstado(estado);

  }

  //---------------------------------------------------------
  // Actualizar operación completa
  //---------------------------------------------------------

  Future<void> actualizarOperacion(
      WorkflowModel workflow) async {

    await WorkflowLocalService.instance
        .actualizarOperacion(workflow);

  }

  //---------------------------------------------------------
  // Finalizar operación
  //---------------------------------------------------------

  Future<void> finalizarOperacion()
      async {

    print("=================================");
    print("WORKFLOW MANAGER");
    print("Finalizar operación");

    await WorkflowLocalService.instance
        .eliminarOperacion();

  }

}
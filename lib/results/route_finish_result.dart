/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// route_finish_result.dart
///
/// Carpeta:
/// lib/results/
///
/// Descripción:
///
/// Resultado consolidado del proceso de finalización
/// de una ruta.
///
/// Responsabilidades:
///
/// • Exponer el resumen actualizado de la ruta.
/// • Exponer el resultado de sincronización de movimientos.
/// • Exponer el resultado de sincronización de evidencias.
/// • Indicar si la ruta puede finalizar.
/// • Proporcionar un mensaje informativo para la UI.
///
/// ===========================================================

import '../models/route_summary.dart';
import '../services/sync/movimiento_sync_service.dart';
import '../services/sync/evidencia_sync_service.dart';

class RouteFinishResult {

  
  final bool success;

  final bool puedeFinalizar;

  final String mensaje;

  final RouteSummary resumen;

  const RouteFinishResult({
    required this.success,
    required this.puedeFinalizar,
    required this.mensaje,
    required this.resumen,
  });

}
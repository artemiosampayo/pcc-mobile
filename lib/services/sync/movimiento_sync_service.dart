/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// movimiento_sync_service.dart
///
/// Carpeta:
/// lib/services/sync/
///
/// Descripción:
///
/// Sincroniza la cola local de movimientos de envío
/// con PCC API.
///
/// Responsabilidades:
///
/// • Consultar movimientos pendientes en SQLite.
/// • Enviar cada movimiento a PCC API.
/// • Marcar como sincronizados los movimientos exitosos.
/// • Registrar errores sin eliminar movimientos pendientes.
/// • Continuar procesando el resto del lote si uno falla.
///
/// ===========================================================

import '../api/mobile_service.dart';
import '../local/movimiento_local_service.dart';
import 'package:flutter/foundation.dart';

class MovimientoSyncService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final MovimientoSyncService instance =
      MovimientoSyncService._();

  MovimientoSyncService._();

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final MobileService _mobileService =
      MobileService();

  final MovimientoLocalService _localService =
      MovimientoLocalService.instance;

  //----------------------------------------------------------
  // Sincronizar movimientos pendientes
  //----------------------------------------------------------

  Future<MovimientoSyncResult> sincronizarPendientes({
    required String token,
  }) async {

    final pendientes =
        await _localService.obtenerPendientes();

    int sincronizados = 0;
    int errores = 0;

    for (final movimiento in pendientes) {

      final uuid =
          movimiento['uuid_sincronizacion']
              .toString();

      try {

        await _mobileService.registrarMovimiento(
          token: token,
          movimiento: movimiento,
        );

        await _localService.marcarSincronizado(
          uuid,
        );

        sincronizados++;

      } catch (e) {
        debugPrint(
          'SYNC MOVIMIENTO ERROR - UUID: $uuid - ERROR: $e',
        );
            await _localService.registrarError(
          uuid,
          e.toString(),
        );

        errores++;

      }

    }

    return MovimientoSyncResult(
      total: pendientes.length,
      sincronizados: sincronizados,
      errores: errores,
    );

  }

}

//============================================================
// RESULTADO DE SINCRONIZACIÓN
//============================================================

class MovimientoSyncResult {

  final int total;

  final int sincronizados;

  final int errores;

  const MovimientoSyncResult({
    required this.total,
    required this.sincronizados,
    required this.errores,
  });

  bool get completado =>
      total > 0 &&
      sincronizados == total &&
      errores == 0;

}
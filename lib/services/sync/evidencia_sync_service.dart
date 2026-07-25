/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// evidencia_sync_service.dart
///
/// Carpeta:
/// lib/services/sync/
///
/// Descripción:
///
/// Sincroniza las evidencias almacenadas localmente
/// hacia PCC API.
///
/// Responsabilidades:
///
/// • Consultar evidencias pendientes.
/// • Resolver el id_movimiento remoto.
/// • Preparar el envío de fotografías y firmas.
/// • Marcar evidencias sincronizadas.
/// • Registrar errores de sincronización.
///
/// ===========================================================

import 'package:flutter/foundation.dart';

import '../api/mobile_service.dart';
import '../local/evidencia_local_service.dart';
import '../local/movimiento_remoto_local_service.dart';

class EvidenciaSyncService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final EvidenciaSyncService instance =
      EvidenciaSyncService._();

  EvidenciaSyncService._();

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final MobileService _mobileService =
      MobileService();

  final EvidenciaLocalService _localService =
      EvidenciaLocalService.instance;

  final MovimientoRemotoLocalService
      _movimientoRemotoService =
          MovimientoRemotoLocalService.instance;

  Future<EvidenciaSyncResult> sincronizarPendientes({

    required String token,

  }) async {

    final evidencias =
        await _localService.obtenerPendientes();

    int sincronizadas = 0;
    int errores = 0;

    for (final evidencia in evidencias) {

      final uuidEvidencia =
          evidencia['uuid_evidencia']
              .toString();

      try {

        final uuidMovimiento =
            evidencia['uuid_movimiento']
                .toString();

        final idMovimientoRemoto =
            await _movimientoRemotoService
                .obtenerIdMovimientoRemoto(
                    uuidMovimiento);

        if (idMovimientoRemoto == null) {

          debugPrint(
            'Movimiento remoto no encontrado para $uuidMovimiento',
          );

          continue;

        }

        //------------------------------------------------------
        // Registrar evidencia en PCC API
        //------------------------------------------------------

        await _mobileService.registrarEvidencia(

          token: token,

          idMovimiento: idMovimientoRemoto,

          evidencia: evidencia,

        );

        //------------------------------------------------------
        // Marcar evidencia sincronizada
        //------------------------------------------------------

        await _localService.marcarSincronizada(

          uuidEvidencia,

        );
        sincronizadas++;
        debugPrint(

          'Evidencia sincronizada: $uuidEvidencia',

        );

      } catch (e) {

        await _localService.registrarError(

          uuidEvidencia,

          e.toString(),

        );

        errores++;

      }

    }
    return EvidenciaSyncResult(
      total: evidencias.length,
      sincronizadas: sincronizadas,
      errores: errores,
    );

  }

  

} 
//============================================================
// RESULTADO DE SINCRONIZACIÓN
//============================================================

class EvidenciaSyncResult {

  final int total;

  final int sincronizadas;

  final int errores;

  const EvidenciaSyncResult({
    required this.total,
    required this.sincronizadas,
    required this.errores,
  });

  bool get completado =>
      total > 0 &&
      sincronizadas == total &&
      errores == 0;
}

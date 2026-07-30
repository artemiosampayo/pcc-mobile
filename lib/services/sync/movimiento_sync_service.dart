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
import '../local/movimiento_remoto_local_service.dart';
import '../local/devolucion_local_service.dart';
import '../local/catalogo_devolucion_local_service.dart';

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

        //------------------------------------------------------
        // Construir movimiento a enviar
        //------------------------------------------------------

        final movimientoEnviar =
            Map<String, dynamic>.from(movimiento);

        //------------------------------------------------------
        // Enriquecer descripción de devoluciones
        //------------------------------------------------------

        if (movimiento['codigo_estado'] == 'DEVOLUCION') {

          final devolucion =
              await DevolucionLocalService.instance
                  .obtenerPorUuidMovimiento(
                      uuid,
                  );

          if (devolucion == null) {
            throw Exception(
              'No se encontró la información de la devolución.',
            );
          }

          final idMotivoTexto =
              devolucion['id_motivo_devolucion']?.toString();

          if (idMotivoTexto == null || idMotivoTexto.isEmpty) {
            throw Exception(
              'La devolución no contiene un motivo válido.',
            );
          }

          final idMotivo = int.tryParse(idMotivoTexto);

          if (idMotivo == null) {
            throw Exception(
              'El motivo de devolución "$idMotivoTexto" no es válido.',
            );
          }


          final catalogo =
              await CatalogoDevolucionLocalService.instance
                  .obtenerPorId(
                      idMotivo,
                  );

          if (catalogo == null) {
            throw Exception(
              'No se encontró el motivo de devolución $idMotivo.',
            );
          }
          

          final comentarios =
              (devolucion['comentarios'] ?? '')
                  .toString()
                  .trim();

          final partes = <String>[];

          final codigo =
              (catalogo['codigo'] ?? '')
                  .toString()
                  .trim();

          final descripcionCatalogo =
              (catalogo['descripcion'] ?? '')
                  .toString()
                  .trim();

          if (codigo.isNotEmpty) {
            partes.add(codigo);
          }

          if (descripcionCatalogo.isNotEmpty) {
            partes.add(descripcionCatalogo);
          }

          if (comentarios.isNotEmpty) {
            partes.add(comentarios);
          }

          movimientoEnviar['descripcion'] =
              partes.join(' | ');

          debugPrint(
            'SYNC DEVOLUCION [$uuid] -> ${movimientoEnviar['descripcion']}',
          );
                    
          
          
        }

        //------------------------------------------------------
        // Enviar movimiento
        //------------------------------------------------------

        final response =
            await _mobileService.registrarMovimiento(
                token: token,
                movimiento: movimientoEnviar,
            );

        if (response.success) {

          await MovimientoRemotoLocalService
              .instance
              .guardarRelacion(

                uuid,

                response.idMovimiento,

              );

          await _localService.marcarSincronizado(
            uuid,
          );

          sincronizados++;

        }

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
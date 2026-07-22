/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// inicio_ruta_screen.dart
///
/// Carpeta:
/// lib/screens/ruta/
///
/// Sprint:
/// SPR-002
///
/// Historia:
/// HU-006 - Inicio de Ruta
///
/// Descripción:
///
/// Pantalla que muestra el resumen de la operación
/// antes de comenzar las entregas.
///
/// ===========================================================

import 'package:flutter/material.dart';
import '../../core/workflow/workflow_manager.dart';
import '../../models/workflow_model.dart';
import '../../widgets/operation_header.dart';
import '../../services/local/envio_local_service.dart';
import '../../services/local/movimiento_local_service.dart';
import '../../services/local/session_local_service.dart';
import '../../services/sync/movimiento_sync_service.dart';
import '../../core/enums/operation_state.dart';
import 'mi_ruta_screen.dart';
import '../../services/device/location_service.dart';

class InicioRutaScreen extends StatefulWidget {

  const InicioRutaScreen({
    super.key,
  });

  @override
  State<InicioRutaScreen> createState() =>
      _InicioRutaScreenState();

}

class _InicioRutaScreenState
    extends State<InicioRutaScreen> {
      WorkflowModel? workflow;

      bool loading = true;

      bool iniciandoRuta = false;

      final EnvioLocalService envioLocalService =
          EnvioLocalService();

      final MovimientoLocalService movimientoLocalService =
          MovimientoLocalService.instance;

      final MovimientoSyncService movimientoSyncService =
          MovimientoSyncService.instance;

    @override
    void initState() {

      super.initState();

      cargarWorkflow();

    }
    Future<void> cargarWorkflow() async {

  workflow =
      await WorkflowManager.instance
          .obtenerOperacion();


  if (!mounted) return;

  setState(() {

    loading = false;

  });

}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Inicio de Ruta",
        ),

      ),

      body: loading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : workflow == null
        ? const Center(
            child: Text(
              'No existe una operación activa.',
            ),
          )
        : Column(
            children: [

              OperationHeader(
                workflow: workflow!,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          const Icon(
                            Icons.local_shipping,
                            size: 56,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          const Text(
                            'Todo listo para iniciar la ruta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          const Text(
                            'Confirma el inicio cuando la unidad '
                            'esté lista para comenzar su recorrido.',
                            textAlign: TextAlign.center,
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ],
            
          ),
          bottomNavigationBar:
    loading || workflow == null
        ? null
        : SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: iniciandoRuta
                    ? null
                    : () async {

                        final confirmar =
                            await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Iniciar Ruta',
                              ),
                              content: const Text(
                                'Al confirmar, la unidad iniciará '
                                'formalmente su recorrido y las guías '
                                'cambiarán al estado EN RUTA.\n\n'
                                '¿Desea continuar?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    );
                                  },
                                  child: const Text(
                                    'Cancelar',
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },
                                  child: const Text(
                                    'Iniciar Ruta',
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmar != true) {
                          return;
                        }

                        setState(() {
                          iniciandoRuta = true;
                        });

                        try {

                          final operacionActual = workflow;

                          if (operacionActual == null) {
                            throw Exception(
                              'No existe una operación activa.',
                            );
                          }

                          if (
                              operacionActual.idOperacion == null ||
                              operacionActual.idUbicacion == null ||
                              operacionActual.idOperador == null ||
                              operacionActual.idRuta == null
                          ) {
                            throw Exception(
                              'La operación no contiene todos los datos requeridos.',
                            );
                          }

                          final envios =
                              await envioLocalService
                                  .obtenerEnvios();

                          if (envios.isEmpty) {
                            throw Exception(
                              'El manifiesto de la ruta no contiene guías.',
                            );
                          }

                          //----------------------------------------------------------
                          // Obtener ubicación del dispositivo
                          //----------------------------------------------------------

                          final ubicacion =
                              await LocationService.instance
                                  .obtenerUbicacion();

                          debugPrint(
                            'GPS EN_RUTA -> '
                            '${ubicacion.latitud}, '
                            '${ubicacion.longitud}',
                          );

                          //----------------------------------------------------------
                          // Crear movimientos EN_RUTA
                          //----------------------------------------------------------

                          final movimientosCreados =
                              await movimientoLocalService
                                  .crearLoteEnRuta(
                            idOperacion: operacionActual.idOperacion!,
                            envios: envios,
                            idUbicacion: operacionActual.idUbicacion!,
                            idEmpleado: operacionActual.idOperador!,
                            idRuta: operacionActual.idRuta!,
                            latitud: ubicacion.latitud,
                            longitud: ubicacion.longitud,
                          );

                          final session =
                              await SessionLocalService.instance
                                  .obtenerSesion();

                          if (session == null) {
                            throw Exception(
                              'No existe una sesión activa para sincronizar.',
                            );
                          }

                          final resultadoSync =
                              await movimientoSyncService
                                  .sincronizarPendientes(
                            token: session.token,
                          );

                          debugPrint(
                            'EN_RUTA - Movimientos locales creados: '
                            '$movimientosCreados',
                          );

                          debugPrint(
                            'EN_RUTA - Sincronización: '
                            '${resultadoSync.sincronizados}/'
                            '${resultadoSync.total}. '
                            'Errores: ${resultadoSync.errores}',
                          );

                          if (resultadoSync.errores > 0) {
                            throw Exception(
                              'No fue posible sincronizar todos los movimientos EN_RUTA.',
                            );
                          }

                          await WorkflowManager.instance
                              .cambiarEstado(
                            OperationState.enRuta,
                          );

                          if (!mounted) {
                            return;
                          }

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MiRutaScreen(),
                            ),
                          );

                        } catch (e) {

                          if (!mounted) return;

                          setState(() {
                            iniciandoRuta = false;
                          });

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'No fue posible iniciar la ruta: $e',
                              ),
                            ),
                          );

                        }

                      },
                icon: const Icon(
                  Icons.play_arrow,
                ),
                label: const Text(
                  'INICIAR RUTA',
                ),
              ),
            ),
          ),
    );

  }

}
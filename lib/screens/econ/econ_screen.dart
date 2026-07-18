import 'package:flutter/material.dart';
import '../scanner/barcode_scanner_screen.dart';
import '../../services/local/envio_local_service.dart';
import '../../services/device/device_feedback_service.dart';
import '../../core/workflow/workflow_manager.dart';
import '../../models/workflow_model.dart';
import '../../widgets/operation_header.dart';
import '../../services/api/mobile_service.dart';
import '../../services/local/session_local_service.dart';
import '../../core/enums/operation_state.dart';
import '../ruta/inicio_ruta_screen.dart';
import '../../services/local/movimiento_local_service.dart';
import '../../services/sync/movimiento_sync_service.dart';

class EconScreen extends StatefulWidget {

  const EconScreen({
    super.key,
  });

  @override
  State<EconScreen> createState() =>
      _EconScreenState();

}

class _EconScreenState
    extends State<EconScreen> {

  final MobileService mobileService =
    MobileService();

  final EnvioLocalService service =
      EnvioLocalService();

  final MovimientoLocalService movimientoService =
    MovimientoLocalService.instance;

  final MovimientoSyncService movimientoSyncService =
    MovimientoSyncService.instance;

  bool confirmandoEcon = false;

  WorkflowModel? workflow;

  List<Map<String,dynamic>>
      envios = [];

  bool loading = true;

  int totalEscaneadas = 0;

  int totalPendientes = 0;

  bool procesandoEscaneo = false;

  @override
  void initState() {

    super.initState();

    cargar();

  }

Future<void> cargar() async {

  workflow =
      await WorkflowManager.instance
          .obtenerOperacion();

  final session =
      await SessionLocalService.instance
          .obtenerSesion();

  // Estos pueden ir aquí.
  print('=================================');
  print('ECON - CARGAR INICIADO');
  print('ECON - WORKFLOW EXISTE: ${workflow != null}');
  print('ECON - ID UBICACIÓN WORKFLOW: ${workflow?.idUbicacion}');
  print('ECON - SESIÓN EXISTE: ${session != null}');
  print('ECON - ID UBICACIÓN SESIÓN: ${session?.idUbicacion}');
  print('=================================');

  if (
      session != null &&
      workflow?.idUbicacion != null
  ) {

    try {

      final guiasServidor =
          await mobileService
              .obtenerGuiasRecepcionadas(
        session.token,
        workflow!.idUbicacion!,
      );

      // Estos deben quedarse aquí porque
      // guiasServidor solamente existe dentro del try.
      print('ECON - GUÍAS RECIBIDAS API: ${guiasServidor.length}');
      print('ECON - GUÍAS API: $guiasServidor');

      final nuevasGuias =
          await service
              .sincronizarNuevasGuias(
        guiasServidor,
      );

      print(
        'ECON - NUEVAS GUÍAS INSERTADAS SQLITE: '
        '$nuevasGuias',
      );

    } catch (e) {

      print(
        'ECON - No fue posible actualizar '
        'las guías: $e',
      );

    }

  }

  envios =
      await service.obtenerEnvios();

  totalEscaneadas =
      envios.where(
        (e) => e['escaneada'] == 1,
      ).length;

  totalPendientes =
      envios.length -
      totalEscaneadas;

  if (!mounted) return;

  setState(() {
    loading = false;
  });

}
  Future<void> escanearGuia() async {

  if (procesandoEscaneo) {
    return;
  }

  procesandoEscaneo = true;

  final codigo =
      await Navigator.push<String>(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const BarcodeScannerScreen(),

    ),

  );

  procesandoEscaneo = false;

  if (codigo == null) {
    return;
  }

  final envio =
      await service.buscarPorGuia(
        codigo,
      );

  if (envio == null) {

    await DeviceFeedbackService.instance.scanError();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          'La guía no pertenece a esta operación.',
        ),

      ),

    );

    return;

  }

  if (envio['escaneada'] == 1) {

    //--------------------------------------------------------
    // Guía ya cargada en ECON
    //
    // Un segundo escaneo retira la guía del manifiesto
    // mientras ECON permanece abierto.
    //--------------------------------------------------------

    await service.desmarcarEscaneada(
      int.parse(
        envio['id_envio'].toString(),
      ),
    );

    await DeviceFeedbackService.instance
        .scanDuplicate();

    await cargar();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Guía retirada del ECON.',
        ),
      ),
    );

    return;

  }

  await service.marcarEscaneada(
    envio['id_envio'],
  );
  await DeviceFeedbackService.instance.scanSuccess();

  await cargar();

}

  @override
  Widget build(BuildContext context) {
    final enviosEscaneados =
    envios
        .where(
          (e) => e['escaneada'] == 1,
        )
        .toList();

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          "ECON",
        ),

      ),
    
      floatingActionButton:

        FloatingActionButton.extended(

          onPressed:
              escanearGuia,

          icon:
              const Icon(
                Icons.qr_code_scanner,
              ),

          label:
              const Text(
                "ESCANEAR",
              ),

        ),
      body: SafeArea(

  child:

  loading

  ?


      const Center(

        child:
            CircularProgressIndicator(),

      )

      :

      Column(

        children: [

          if (workflow != null) 
          OperationHeader(
            workflow: workflow!,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Column(
                            children: [

                              const Text(
                                "ECON",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                totalEscaneadas.toString(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                        ),

                     

                      ],
                    ),

                    const SizedBox(height: 16),

                    

                  ],
                ),
              ),
            ),
          ),
          Expanded(

            child:

            ListView.builder(

              itemCount:
                 enviosEscaneados.length,

              itemBuilder:

                  (_, index) {

                final e =
                  enviosEscaneados[index];

                return Card(

                  margin:

                      const EdgeInsets.symmetric(

                    horizontal: 12,

                    vertical: 5,

                  ),

                  child: ListTile(

                    leading: Icon(

                      e['escaneada'] == 1
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,

                      color:

                          e['escaneada'] == 1

                              ? Colors.green

                              : Colors.grey,

),


                    title:

                        Text(

                      e['numero_guia'],

                    ),

                    subtitle:

                        Text(

                      e['cliente'],

                    ),

                    trailing: Column(

                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [

                        Text(
                          e['estado_envio'],
                        ),

                        const SizedBox(height: 4),

                        Text(

                          e['escaneada'] == 1

                              ? "Escaneada"

                              : "Pendiente",

                          style: TextStyle(

                            color:

                                e['escaneada'] == 1

                                    ? Colors.green

                                    : Colors.orange,

                            fontWeight:
                                FontWeight.bold,

                          ),

                        ),

                      ],

                    ),

                  ),

                );

              },

            ),

          ),
Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  175, // Reserva espacio para el botón ESCANEAR
                  16,
                ),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: totalEscaneadas > 0 && !confirmandoEcon
          ? () async {

              final confirmar =
                  await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirmar ECON',
                    ),
                    content: Text(
                      'Se confirmará un manifiesto con '
                      '$totalEscaneadas guía(s).\n\n'
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
                          'Confirmar',
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmar != true) {
                return;
              }

              try {

                setState(() {
                  confirmandoEcon = true;
                });

                final guiasEcon =
                    envios
                        .where(
                          (e) => e['escaneada'] == 1,
                        )
                        .toList();

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

                final movimientosCreados =
                    await movimientoService.crearLoteEcon(
                  idOperacion: operacionActual.idOperacion!,
                  envios: guiasEcon,
                  idUbicacion: operacionActual.idUbicacion!,
                  idEmpleado: operacionActual.idOperador!,
                  idRuta: operacionActual.idRuta!,
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

                print(
                  'ECON - Sincronización: '
                  '${resultadoSync.sincronizados}/'
                  '${resultadoSync.total}. '
                  'Errores: ${resultadoSync.errores}',
                );

                print(
                  'ECON - Movimientos locales creados: '
                  '$movimientosCreados',
                );

                final guiasEliminadas =
                    await service.eliminarGuiasNoEscaneadas();

                await WorkflowManager.instance.cambiarEstado(
                  OperationState.econConfirmado,
                );

                if (!context.mounted) return;

                print(
                  'ECON CONFIRMADO - Guías no utilizadas eliminadas: '
                  '$guiasEliminadas',
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const InicioRutaScreen(),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No fue posible confirmar el ECON: $e',
                    ),
                  ),
                );
              }

              // Aquí en el siguiente bloque
              // cambiaremos el Workflow
              // y navegaremos a InicioRutaScreen.

            }
          : null,
      icon: const Icon(
        Icons.check_circle,
      ),
      label: const Text(
        'CONFIRMAR ECON',
      ),
    ),
  ),
),
        ],

      ),
      ),
    );

  }

}
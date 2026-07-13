/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// mi_ruta_screen.dart
///
/// Carpeta:
/// lib/screens/ruta/
///
/// Sprint:
/// SPR-002
///
/// Historia:
/// HU-007 - Mi Ruta
///
/// Descripción:
///
/// Pantalla principal de operación del chofer.
///
/// Muestra:
///
/// • Información de la operación activa.
/// • Resumen de guías de la ruta.
/// • Guías pendientes.
/// • Guías entregadas.
/// • Guías en devolución.
///
/// Las guías mostradas corresponden únicamente al manifiesto
/// confirmado previamente durante el proceso ECON.
///
/// ===========================================================

import 'package:flutter/material.dart';

import '../../core/workflow/workflow_manager.dart';
import '../../models/workflow_model.dart';
import '../../services/local/envio_local_service.dart';
import '../../widgets/operation_header.dart';

class MiRutaScreen extends StatefulWidget {

  const MiRutaScreen({
    super.key,
  });

  @override
  State<MiRutaScreen> createState() =>
      _MiRutaScreenState();

}

class _MiRutaScreenState
    extends State<MiRutaScreen> {

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final EnvioLocalService envioLocalService =
      EnvioLocalService();

  //----------------------------------------------------------
  // Estado
  //----------------------------------------------------------

  WorkflowModel? workflow;

  List<Map<String, dynamic>> envios = [];

  bool loading = true;

  //----------------------------------------------------------
  // Ciclo de vida
  //----------------------------------------------------------

  @override
  void initState() {

    super.initState();

    cargarDatos();

  }

  //----------------------------------------------------------
  // Cargar datos de la operación
  //----------------------------------------------------------

  Future<void> cargarDatos() async {

    final operacionActual =
        await WorkflowManager.instance
            .obtenerOperacion();

    final guiasRuta =
        await envioLocalService
            .obtenerEnvios();

    if (!mounted) {
      return;
    }

    setState(() {

      workflow =
          operacionActual;

      envios =
          guiasRuta;

      loading =
          false;

    });

  }

  //----------------------------------------------------------
  // Contadores
  //----------------------------------------------------------

  int get totalGuias =>
      envios.length;

  int get totalPendientes =>
      envios.where(
        (envio) {

          final estado =
              envio['estatus_local']
                  ?.toString()
                  .toUpperCase();

          return estado != 'ENTREGADA' &&
              estado != 'DEVOLUCION';

        },
      ).length;

  int get totalEntregadas =>
      envios.where(
        (envio) =>
            envio['estatus_local']
                ?.toString()
                .toUpperCase() ==
            'ENTREGADA',
      ).length;

  int get totalDevoluciones =>
      envios.where(
        (envio) =>
            envio['estatus_local']
                ?.toString()
                .toUpperCase() ==
            'DEVOLUCION',
      ).length;

  //----------------------------------------------------------
  // Build
  //----------------------------------------------------------

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Mi Ruta',
        ),

      ),

      body:
          loading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : workflow == null
                  ? const Center(
                      child: Text(
                        'No existe una operación activa.',
                      ),
                    )
                  : Column(

                      children: [

                        //--------------------------------------------------
                        // Header de operación
                        //--------------------------------------------------

                        OperationHeader(
                          workflow:
                              workflow!,
                        ),

                        //--------------------------------------------------
                        // Resumen
                        //--------------------------------------------------

                        Padding(

                          padding:
                              const EdgeInsets.all(
                            12,
                          ),

                          child: Row(

                            children: [

                              Expanded(
                                child:
                                    _ResumenCard(
                                  titulo:
                                      'Total',
                                  valor:
                                      totalGuias,
                                  icono:
                                      Icons.inventory_2,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child:
                                    _ResumenCard(
                                  titulo:
                                      'Pendientes',
                                  valor:
                                      totalPendientes,
                                  icono:
                                      Icons.schedule,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child:
                                    _ResumenCard(
                                  titulo:
                                      'Entregas',
                                  valor:
                                      totalEntregadas,
                                  icono:
                                      Icons.check_circle,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child:
                                    _ResumenCard(
                                  titulo:
                                      'Devolución',
                                  valor:
                                      totalDevoluciones,
                                  icono:
                                      Icons.assignment_return,
                                ),
                              ),

                            ],

                          ),

                        ),

                        //--------------------------------------------------
                        // Título de manifiesto
                        //--------------------------------------------------

                        Padding(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          child: Row(

                            children: [

                              const Expanded(
                                child: Text(
                                  'Guías de la Ruta',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              Text(
                                '${envios.length} guías',
                              ),

                            ],

                          ),

                        ),

                        //--------------------------------------------------
                        // Lista de guías
                        //--------------------------------------------------

                        Expanded(

                          child:
                              envios.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No existen guías '
                                        'en la ruta.',
                                      ),
                                    )
                                  : RefreshIndicator(

                                      onRefresh:
                                          cargarDatos,

                                      child:
                                          ListView.separated(

                                        padding:
                                            const EdgeInsets.fromLTRB(
                                          12,
                                          4,
                                          12,
                                          24,
                                        ),

                                        itemCount:
                                            envios.length,

                                        separatorBuilder:
                                            (
                                          context,
                                          index,
                                        ) =>
                                                const SizedBox(
                                          height: 8,
                                        ),

                                        itemBuilder:
                                            (
                                          context,
                                          index,
                                        ) {

                                          final envio =
                                              envios[index];

                                          return _GuiaRutaCard(
                                            envio:
                                                envio,
                                          );

                                        },

                                      ),

                                    ),

                        ),

                      ],

                    ),

    );

  }

}

//============================================================
// TARJETA DE RESUMEN
//============================================================

class _ResumenCard extends StatelessWidget {

  final String titulo;

  final int valor;

  final IconData icono;

  const _ResumenCard({

    required this.titulo,

    required this.valor,

    required this.icono,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 6,
        ),

        child: Column(

          children: [

            Icon(
              icono,
              size: 24,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              valor.toString(),

              style:
                  const TextStyle(

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 2,
            ),

            FittedBox(

              fit:
                  BoxFit.scaleDown,

              child: Text(

                titulo,

                style:
                    const TextStyle(
                  fontSize: 12,
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}

//============================================================
// TARJETA DE GUÍA
//============================================================

class _GuiaRutaCard extends StatelessWidget {

  final Map<String, dynamic> envio;

  const _GuiaRutaCard({

    required this.envio,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final numeroGuia =
        envio['numero_guia']
            ?.toString() ??
        '';

    final pedido =
        envio['pedido']
            ?.toString() ??
        '';

    final cliente =
        envio['nombre_cliente']
            ?.toString() ??
        envio['cliente']
            ?.toString() ??
        '';

    final colonia =
        envio['colonia']
            ?.toString() ??
        '';

    final ciudad =
        envio['ciudad']
            ?.toString() ??
        '';

    final estatus =
        envio['estatus_local']
            ?.toString()
            .toUpperCase() ??
        'PENDIENTE';

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(
          14,
        ),

        child: Row(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            //--------------------------------------------------
            // Estado
            //--------------------------------------------------

            const Padding(

              padding:
                  EdgeInsets.only(
                top: 4,
              ),

              child: Icon(
                Icons.local_shipping_outlined,
                size: 30,
              ),

            ),

            const SizedBox(
              width: 12,
            ),

            //--------------------------------------------------
            // Información
            //--------------------------------------------------

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    numeroGuia,

                    style:
                        const TextStyle(

                      fontSize: 16,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  if (pedido.isNotEmpty) ...[

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Pedido: $pedido',
                    ),

                  ],

                  if (cliente.isNotEmpty) ...[

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      cliente,
                    ),

                  ],

                  if (
                      colonia.isNotEmpty ||
                      ciudad.isNotEmpty
                  ) ...[

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      [
                        colonia,
                        ciudad,
                      ]
                          .where(
                            (valor) =>
                                valor.isNotEmpty,
                          )
                          .join(', '),
                    ),

                  ],

                  const SizedBox(
                    height: 8,
                  ),

                  Text(

                    estatus == 'CARGADA'
                        ? 'Pendiente de entrega'
                        : estatus,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),

                  ),

                ],

              ),

            ),

            //--------------------------------------------------
            // Detalle
            //--------------------------------------------------

            IconButton(

              onPressed: () {

                // Próximo bloque:
                // detalle de la guía.

              },

              icon:
                  const Icon(
                Icons.chevron_right,
              ),

            ),

          ],

        ),

      ),

    );

  }

}
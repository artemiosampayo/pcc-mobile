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
import '../scanner/barcode_scanner_screen.dart';
import '../../services/device/device_feedback_service.dart';
import '../entrega/entrega_screen.dart';

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

  String filtroSeleccionado = 'TODAS';

  final Set<String> guiasSeleccionadas = {};

  bool procesandoEscaneo = false;

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


  List<Map<String, dynamic>> get enviosFiltrados {

    switch (filtroSeleccionado) {

      case 'PENDIENTES':

        return envios.where(
          (envio) {

            final estado =
                envio['estatus_local']
                    ?.toString()
                    .toUpperCase();

            return estado != 'ENTREGADA' &&
                estado != 'DEVOLUCION';

          },
        ).toList();

      case 'ENTREGAS':

        return envios.where(
          (envio) =>
              envio['estatus_local']
                  ?.toString()
                  .toUpperCase() ==
              'ENTREGADA',
        ).toList();

      case 'DEVOLUCIONES':

        return envios.where(
          (envio) =>
              envio['estatus_local']
                  ?.toString()
                  .toUpperCase() ==
              'DEVOLUCION',
        ).toList();

      default:

        return envios;

    }

  }

  //----------------------------------------------------------
// Selección temporal de guías
//----------------------------------------------------------

  void toggleSeleccionGuia(String numeroGuia,) {

    setState(() {

      if (guiasSeleccionadas.contains(numeroGuia)) {

        guiasSeleccionadas.remove(numeroGuia);

      } else {

        guiasSeleccionadas.add(numeroGuia);

      }

    });

}
//----------------------------------------------------------
// Escaneo de guía para selección
//----------------------------------------------------------

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

  //--------------------------------------------------------
  // Buscar únicamente entre las guías pendientes
  //--------------------------------------------------------

  Map<String, dynamic>? envioEncontrado;

  for (final envio in envios) {

    final numeroGuia =
        envio['numero_guia']
            ?.toString();

    final estado =
        envio['estatus_local']
            ?.toString()
            .toUpperCase();

    final esPendiente =
        estado != 'ENTREGADA' &&
        estado != 'DEVOLUCION';

    if (
        numeroGuia == codigo &&
        esPendiente
    ) {
      envioEncontrado = envio;
      break;
    }

  }

  //--------------------------------------------------------
  // La guía no pertenece a las pendientes de la ruta
  //--------------------------------------------------------

  if (envioEncontrado == null) {

    await DeviceFeedbackService
        .instance
        .scanError();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'La guía no pertenece a las '
          'guías pendientes de esta ruta.',
        ),
      ),
    );

    return;

  }

  //--------------------------------------------------------
  // Seleccionar / deseleccionar
  //--------------------------------------------------------

  final numeroGuia =
      envioEncontrado['numero_guia']
          .toString();

  toggleSeleccionGuia(
    numeroGuia,
  );

  await DeviceFeedbackService
      .instance
      .scanSuccess();

}

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
      floatingActionButton:
        filtroSeleccionado == 'PENDIENTES'
            ? FloatingActionButton.extended(
                onPressed:
                    procesandoEscaneo
                        ? null
                        : escanearGuia,
                icon: const Icon(
                  Icons.qr_code_scanner,
                ),
                label: const Text(
                  'ESCANEAR',
                ),
              )
            : null,
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
                          workflow: workflow!,
                          compact: true,
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
                                      titulo: 'Todas',
                                      valor: totalGuias,
                                      icono: Icons.inventory_2,
                                      seleccionado:
                                          filtroSeleccionado == 'TODAS',
                                      onTap: () {
                                        setState(() {
                                          filtroSeleccionado = 'TODAS';
                                        });
                                      },
                                    ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child:
                                    _ResumenCard(
                                      titulo: 'Pendientes',
                                      valor: totalPendientes,
                                      icono: Icons.schedule,
                                      seleccionado:
                                          filtroSeleccionado == 'PENDIENTES',
                                      onTap: () {
                                        setState(() {
                                          filtroSeleccionado = 'PENDIENTES';
                                        });
                                      },
                                    ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child:
                                    _ResumenCard(
                                      titulo: 'Entregas',
                                      valor: totalEntregadas,
                                      icono: Icons.check_circle,
                                      seleccionado:
                                          filtroSeleccionado == 'ENTREGAS',
                                      onTap: () {
                                        setState(() {
                                          filtroSeleccionado = 'ENTREGAS';
                                        });
                                      },
                                    ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child:
                                    _ResumenCard(
                                      titulo: 'Devolución',
                                      valor: totalDevoluciones,
                                      icono: Icons.assignment_return,
                                      seleccionado:
                                          filtroSeleccionado == 'DEVOLUCIONES',
                                      onTap: () {
                                        setState(() {
                                          filtroSeleccionado = 'DEVOLUCIONES';
                                        });
                                      },
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
                                '${enviosFiltrados.length} guías',
                              ),

                            ],

                          ),

                        ),

                        //--------------------------------------------------
                        // Lista de guías
                        //--------------------------------------------------

                        Expanded(

                          child:
                              enviosFiltrados.isEmpty
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

                                        itemCount: enviosFiltrados.length,

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

                                          final envio = enviosFiltrados[index];

                                          final numeroGuia =
                                            envio['numero_guia']
                                                ?.toString() ??
                                            '';

                                        return _GuiaRutaCard(
                                          envio: envio,
                                          seleccionada:
                                              guiasSeleccionadas.contains(
                                            numeroGuia,
                                          ),
                                          modoSeleccion:
                                              filtroSeleccionado == 'PENDIENTES',
                                          onSeleccionChanged: () {
                                            toggleSeleccionGuia(
                                              numeroGuia,
                                            );
                                          },
                                        );

                                        },

                                      ),

                                    ),

                        ),

                      ],

                    ),
bottomNavigationBar:
    filtroSeleccionado == 'PENDIENTES'
        ? SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, -2),
                    color: Color.fromARGB(
                      30,
                      0,
                      0,
                      0,
                    ),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    '${guiasSeleccionadas.length} '
                    'guías seleccionadas',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                            guiasSeleccionadas.isEmpty
                                ? null
                                : () async {

                                    //------------------------------------------------
                                    // Obtener guías seleccionadas
                                    //------------------------------------------------

                                    final enviosSeleccionados =
                                        envios.where(
                                      (envio) {

                                        final numeroGuia =
                                            envio['numero_guia']
                                                    ?.toString() ??
                                                '';

                                        return guiasSeleccionadas
                                            .contains(numeroGuia);

                                      },
                                    ).toList();

                                    //------------------------------------------------
                                    // Abrir flujo de entrega
                                    //------------------------------------------------

                                    final entregaRealizada =
                                        await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EntregaScreen(
                                          envios:
                                              enviosSeleccionados,
                                        ),
                                      ),
                                    );

                                    //------------------------------------------------
                                    // Entrega cancelada
                                    //------------------------------------------------

                                    if (entregaRealizada != true) {
                                      return;
                                    }

                                    //------------------------------------------------
                                    // Limpiar selección temporal
                                    //------------------------------------------------

                                    guiasSeleccionadas.clear();

                                    //------------------------------------------------
                                    // Recargar estado local de la ruta
                                    //------------------------------------------------

                                    await cargarDatos();

                                    //------------------------------------------------
                                    // Validar contexto
                                    //------------------------------------------------

                                    if (!mounted) {
                                      return;
                                    }

                                    //------------------------------------------------
                                    // Cambiar a pestaña Entregas
                                    //------------------------------------------------

                                    setState(() {
                                      filtroSeleccionado =
                                          'ENTREGAS';
                                    });

                                  },
                          icon: const Icon(
                            Icons.check_circle_outline,
                          ),
                          label: const Text(
                            'ENTREGAR',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green.shade700,
                            foregroundColor:
                                Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              guiasSeleccionadas.isEmpty
                                  ? null
                                  : () {
                                      // Próximo bloque:
                                      // flujo de devolución.
                                    },
                          icon: const Icon(
                            Icons.assignment_return_outlined,
                          ),
                          label: const Text(
                            'DEVOLVER',
                          ),
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                Colors.red.shade700,
                            side: BorderSide(
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),
          )
        : null,
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

  final bool seleccionado;

  final VoidCallback onTap;

  const _ResumenCard({

    required this.titulo,

    required this.valor,

    required this.icono,

    required this.seleccionado,
  
    required this.onTap,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Card(
      elevation: seleccionado ? 4 : 1,
      color: seleccionado
          ? Colors.orange.shade100
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 6,
          ),
          child: Column(
            children: [
              Icon(
                icono,
                size: 24,
                color: seleccionado
                    ? Colors.orange.shade800
                    : Colors.grey.shade700,
              ),

              const SizedBox(height: 6),

              Text(
                valor.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: seleccionado
                      ? Colors.orange.shade900
                      : null,
                ),
              ),

              const SizedBox(height: 2),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: seleccionado
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
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

  final bool seleccionada;

  final VoidCallback onSeleccionChanged;

  final bool modoSeleccion;
  
  const _GuiaRutaCard({

    required this.envio,
    required this.seleccionada,
    required this.modoSeleccion,
    required this.onSeleccionChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final numeroGuia =
        envio['numero_guia']
            ?.toString() ??
        '';

    return Card(
        margin: EdgeInsets.zero,
        elevation: seleccionada ? 2 : 1,
        color: seleccionada
            ? Colors.orange.shade50
            : null,
        child: InkWell(
          onTap: modoSeleccion
              ? onSeleccionChanged
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            child: Row(
              children: [

                if (modoSeleccion)
                    Checkbox(
                      value: seleccionada,
                      activeColor:
                          Colors.orange.shade700,
                      onChanged: (_) {
                        onSeleccionChanged();
                      },
                    ),

                Expanded(
                  child: Text(
                    numeroGuia,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: seleccionada
                          ? Colors.orange.shade900
                          : const Color.fromARGB(
                              255,
                              5,
                              61,
                              126,
                            ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    // Próximo bloque:
                    // abrir detalle de la guía.
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                  ),
                ),

              ],
            ),
          ),
        ),
      );

  }

}
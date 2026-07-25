/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// finalizar_ruta_screen.dart
///
/// Carpeta:
/// lib/screens/ruta/
///
/// Sprint:
/// SPR-003
///
/// Historia:
/// HU-008 - Finalizar Ruta
///
/// Descripción:
///
/// Pantalla que permite visualizar el resumen final
/// de la operación antes de concluir la ruta.
///
/// Responsabilidades:
///
/// • Mostrar el resumen operativo.
/// • Mostrar pendientes de sincronización.
/// • Permitir sincronizar información.
/// • Permitir finalizar la operación.
/// • Delegar toda la lógica al RouteFinishService.
///
/// ===========================================================

import 'package:flutter/material.dart';

import '../../core/workflow/workflow_manager.dart';
import '../../models/route_summary.dart';
import '../../models/workflow_model.dart';
import '../../services/workflow/route_finish_service.dart';
import '../../widgets/loading_dialog.dart';
import '../../widgets/operation_header.dart';

class FinalizarRutaScreen extends StatefulWidget {
  const FinalizarRutaScreen({
    super.key,
  });

  @override
  State<FinalizarRutaScreen> createState() =>
      _FinalizarRutaScreenState();
}

class _FinalizarRutaScreenState
    extends State<FinalizarRutaScreen> {

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final RouteFinishService service =
      RouteFinishService.instance;

  //----------------------------------------------------------
  // Estado
  //----------------------------------------------------------

  WorkflowModel? workflow;

  RouteSummary? resumen;

  bool loading = true;

  bool procesando = false;

  //----------------------------------------------------------
  // Ciclo de vida
  //----------------------------------------------------------

  @override
  void initState() {

    super.initState();

    cargarResumen();

  }
  //----------------------------------------------------------
  // Cargar información de la operación
  //----------------------------------------------------------

  Future<void> cargarResumen() async {

    final operacionActual =
        await WorkflowManager.instance
            .obtenerOperacion();

    final resumenOperacion =
        await service.obtenerResumen();

    if (!mounted) {
      return;
    }

    setState(() {

      workflow = operacionActual;

      resumen = resumenOperacion;

      loading = false;

    });

  }

  //----------------------------------------------------------
  // Propiedades de apoyo
  //----------------------------------------------------------

  bool get hayPendientes {

    if (resumen == null) {
      return false;
    }

    return resumen!.movimientosPendientes > 0 ||
           resumen!.evidenciasPendientes > 0;

  }

  bool get puedeFinalizar {

    if (resumen == null) {
      return false;
    }

    return resumen!.hayActividad &&
           !hayPendientes;

  }

  String get mensajeEstado {

    if (resumen == null) {
      return '';

    }

    if (!resumen!.hayActividad) {

      return 'No existen entregas ni devoluciones registradas.';

    }

    if (hayPendientes) {

      return 'Existen movimientos pendientes por sincronizar.';

    }

    return 'La operación está lista para finalizar.';

  }

  IconData get iconoEstado {

    if (resumen == null) {
      return Icons.info_outline;
    }

    if (!resumen!.hayActividad) {
      return Icons.warning_amber_rounded;
    }

    if (hayPendientes) {
      return Icons.sync_problem;
    }

    return Icons.check_circle;

  }

  Color get colorEstado {

    if (resumen == null) {
      return Colors.grey;
    }

    if (!resumen!.hayActividad) {
      return Colors.orange;
    }

    if (hayPendientes) {
      return Colors.orange;
    }

    return Colors.green;

  }

    //----------------------------------------------------------
  // Sincronizar pendientes
  //----------------------------------------------------------

  Future<void> sincronizarPendientes() async {

    if (procesando) {
      return;
    }

    setState(() {
      procesando = true;
    });

    LoadingDialog.show(
      context,
      message: 'Sincronizando información...',
    );

    try {

      final resultado =
         await service.finalizarRuta();

      await cargarResumen();

      if (resultado.puedeFinalizar) {

        await WorkflowManager.instance
            .finalizarOperacion();

        if (!mounted) {
          return;
        }

        LoadingDialog.hide();

        Navigator.of(context).pop(true);

        return;
      }

      if (!mounted) {
        return;
      }

      LoadingDialog.hide();

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            resultado.mensaje,
          ),
        ),

      );

    } catch (e) {

      if (!mounted) {
        return;
      }

      LoadingDialog.hide();

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(
            'Ocurrió un error.\n$e',
          ),

        ),

      );

    } finally {

      if (mounted) {

        setState(() {
          procesando = false;
        });

      }

    }

  }

  //----------------------------------------------------------
  // Finalizar ruta
  //----------------------------------------------------------

  Future<void> finalizarRuta() async {

    if (procesando) {
      return;
    }

    setState(() {
      procesando = true;
    });

    LoadingDialog.show(
      context,
      message: 'Finalizando operación...',
    );

    try {

      await WorkflowManager.instance
          .finalizarOperacion();

      if (!mounted) {
        return;
      }

      LoadingDialog.hide();

      Navigator.of(context).pop(true);

    } catch (e) {

      if (!mounted) {
        return;
      }

      LoadingDialog.hide();

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(
            'No fue posible finalizar la ruta.\n$e',
          ),

        ),

      );

    } finally {

      if (mounted) {

        setState(() {
          procesando = false;
        });

      }

    }

  }
    //----------------------------------------------------------
  // Widget Resumen
  //----------------------------------------------------------

  Widget _buildResumenCard({
    required String titulo,
    required int valor,
    required IconData icono,
  }) {

    return Card(

      child: Padding(

        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icono,
              size: 28,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              valor.toString(),

              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),

            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              titulo,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 12,
              ),

            ),

          ],

        ),

      ),

    );

  }

  //----------------------------------------------------------
  // Widget Estado
  //----------------------------------------------------------

  Widget  _buildEstadoCard() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Row(

          children: [

            Icon(

              iconoEstado,

              color: colorEstado,

              size: 42,

            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(

              child: Text(

                mensajeEstado,

                style: const TextStyle(

                  fontSize: 16,

                  fontWeight: FontWeight.w500,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }
  //----------------------------------------------------------
  // Build
  //----------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),

      );

    }

    if (workflow == null || resumen == null) {

      return Scaffold(

        appBar: AppBar(
          title: const Text('Finalizar Ruta'),
        ),

        body: const Center(

          child: Text(
            'No existe una operación activa.',
          ),

        ),

      );

    }

    return Scaffold(

      appBar: AppBar(
        title: const Text('Finalizar Ruta'),
      ),

      body: Column(

        children: [

          OperationHeader(

            workflow: workflow!,

            compact: true,

          ),

          Expanded(

            child: ListView(

              padding: const EdgeInsets.all(16),

              children: [

                Card(

                  child: Padding(

                    padding: const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        const Text(

                          'Resumen Operativo',

                          style: TextStyle(

                            fontSize: 18,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 24),

                        Row(

                          children: [

                            Expanded(

                              child: _buildResumenCard(

                                titulo: 'Entregas',

                                valor: resumen!.totalEntregas,

                                icono: Icons.check_circle,

                              ),

                            ),

                            const SizedBox(width: 12),

                            Expanded(

                              child: _buildResumenCard(

                                titulo: 'Devoluciones',

                                valor: resumen!.totalDevoluciones,

                                icono: Icons.assignment_return,

                              ),

                            ),

                          ],

                        ),

                        const SizedBox(height: 16),

                        Row(

                          children: [

                            Expanded(

                              child: _buildResumenCard(

                                titulo: 'Movimientos',

                                valor: resumen!.movimientosPendientes,

                                icono: Icons.sync,

                              ),

                            ),

                            const SizedBox(width: 12),

                            Expanded(

                              child: _buildResumenCard(

                                titulo: 'Evidencias',

                                valor: resumen!.evidenciasPendientes,

                                icono: Icons.photo_camera,

                              ),

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                _buildEstadoCard(),

              ],

            ),

          ),

        ],

      ),

      bottomNavigationBar: SafeArea(

        minimum: const EdgeInsets.all(16),

        child: SizedBox(

          height: 52,

          child: FilledButton.icon(

            onPressed: procesando
                ? null
                : (puedeFinalizar
                    ? finalizarRuta
                    : sincronizarPendientes),

            icon: Icon(

              puedeFinalizar
                  ? Icons.flag
                  : Icons.sync,

            ),

            label: Text(

              puedeFinalizar
                  ? 'FINALIZAR RUTA'
                  : 'SINCRONIZAR',

            ),

          ),

        ),

      ),

    );

  }

}
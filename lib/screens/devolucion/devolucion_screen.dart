/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// devolucion_screen.dart
///
/// Carpeta:
/// lib/screens/devolucion/
///
/// Sprint:
/// SPR-002
///
/// Historia:
/// HU-009 - Confirmación de Devolución
///
/// Descripción:
///
/// Pantalla para procesar la devolución de una o varias
/// guías seleccionadas desde Mi Ruta.
///
/// Permite:
///
/// • Capturar evidencia fotográfica.
/// • Registrar el motivo de la devolución.
/// • Obtener la ubicación GPS.
/// • Registrar la devolución local.
/// • Sincronizar con PCC.
///
/// ===========================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/authentication/authentication_manager.dart';
import '../../core/workflow/workflow_manager.dart';

import '../../services/device/location_service.dart';
import '../../services/local/devolucion_local_service.dart';
import '../../services/sync/evidencia_sync_service.dart';
import '../../services/sync/movimiento_sync_service.dart';

import '../../widgets/loading_dialog.dart';

import '../../services/local/envio_local_service.dart';

import 'package:uuid/uuid.dart';

import '../../services/local/catalogo_devolucion_local_service.dart';

class DevolucionScreen extends StatefulWidget {

  const DevolucionScreen({
    super.key,
    required this.envios,
  });

  //----------------------------------------------------------
  // Guías seleccionadas
  //----------------------------------------------------------

  final List<Map<String, dynamic>> envios;

  @override
  State<DevolucionScreen> createState() =>
      _DevolucionScreenState();

}

class _DevolucionScreenState
    extends State<DevolucionScreen> {
        //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final DevolucionLocalService devolucionLocalService =
      DevolucionLocalService.instance;

  final CatalogoDevolucionLocalService
    catalogoService =
        CatalogoDevolucionLocalService.instance;

  //----------------------------------------------------------
  // Estado
  //----------------------------------------------------------

  bool realizandoDevolucion = false;

  //----------------------------------------------------------
  // Evidencia fotográfica
  //----------------------------------------------------------

  final ImagePicker imagePicker =
      ImagePicker();

  XFile? fotoEvidencia;

  //----------------------------------------------------------
  // Formulario
  //----------------------------------------------------------

  final TextEditingController
      comentariosController =
          TextEditingController();

  List<Map<String, dynamic>>
      catalogoMotivos = [];

  int? idMotivoSeleccionado;

  final GlobalKey<FormState>
      formKey =
          GlobalKey<FormState>();

  
  //----------------------------------------------------------
  // Cargar catalogo devoluciones
  //----------------------------------------------------------
  Future<void> cargarCatalogo() async {

    catalogoMotivos =
        await catalogoService
            .obtenerCatalogo();

    if (mounted) {

      setState(() {});

    }

  }
  @override
  void initState() {

    super.initState();

    cargarCatalogo();

  }

  //----------------------------------------------------------
  // Tomar fotografía
  //----------------------------------------------------------

  Future<void> tomarFoto() async {

    final XFile? foto =
        await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      fotoEvidencia = foto;
    });

  }
    //----------------------------------------------------------
  // Realizar devolución
  //----------------------------------------------------------

  Future<void> realizarDevolucion() async {
    final currentContext = context;
    //--------------------------------------------------------
    // Evitar doble clic
    //--------------------------------------------------------

    if (realizandoDevolucion) {
      return;
    }

    //--------------------------------------------------------
    // Validar formulario
    //--------------------------------------------------------

    if (!formKey.currentState!.validate()) {
      return;
    }

    //--------------------------------------------------------
    // Validar motivo seleccionado
    //--------------------------------------------------------

    if (idMotivoSeleccionado == null) {
      return;
    }

    //--------------------------------------------------------
    // Validar fotografía
    //--------------------------------------------------------

    if (fotoEvidencia == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe capturar una fotografía.',
          ),
        ),
      );

      return;

    }

    //--------------------------------------------------------
    // Iniciar proceso
    //--------------------------------------------------------

    setState(() {
      realizandoDevolucion = true;
    });
    if (!mounted) return;

    LoadingDialog.show(
      currentContext,
      message: 'Realizando devolución...',
    );
    try {

          //------------------------------------------------------
          // Obtener sesión
          //------------------------------------------------------

          final session =
              await AuthenticationManager.instance
                  .obtenerSesion();

          if (session == null) {
            throw Exception(
              'No existe una sesión activa.',
            );
          }

          //------------------------------------------------------
          // Obtener operación
          //------------------------------------------------------

          final workflow =
              await WorkflowManager.instance
                  .obtenerOperacion();

          if (workflow == null) {
            throw Exception(
              'No existe una operación activa.',
            );
          }

          //------------------------------------------------------
          // Obtener ubicación
          //------------------------------------------------------

          final location =
              await LocationService.instance
                  .obtenerUbicacion();

          if (!location.success) {
            throw Exception(
              location.mensaje,
            );
          }

          //------------------------------------------------------
          // Registrar devolución local
          //------------------------------------------------------
          final uuidOperacion = const Uuid().v4();
          final resultado =
              await devolucionLocalService.realizarDevolucion(

            idOperacion: workflow.idOperacion!,

             uuidOperacion: uuidOperacion,

            envios: widget.envios,

            fotoOrigenPath: fotoEvidencia!.path,

            idMotivoDevolucion: idMotivoSeleccionado!,

            comentarios: comentariosController.text.trim(),

            idUbicacion: session.idUbicacion,

            idEmpleado: session.idEmpleado,

            idRuta: workflow.idRuta!,

            latitud: location.latitud,

            longitud: location.longitud,

          );
          final enviosActualizados =
              await EnvioLocalService()
                  .obtenerEnvios();

          debugPrint("=================================");
          debugPrint("ESTADO LOCAL DESPUÉS DE LA DEVOLUCIÓN");

          for (final envio in enviosActualizados) {
            debugPrint(
              "${envio['numero_guia']} -> ${envio['estatus_local']}",
            );
          }

          if (!mounted) {
            return;
          }

          

          //------------------------------------------------------
          // Sincronizar movimientos
          //------------------------------------------------------

          await MovimientoSyncService.instance
              .sincronizarPendientes(
            token: session.token,
          );

          //------------------------------------------------------
          // Sincronizar evidencias
          //------------------------------------------------------

          await EvidenciaSyncService.instance
              .sincronizarPendientes(
            token: session.token,
          );

          //------------------------------------------------------
          // Regresar a Mi Ruta
          //------------------------------------------------------

          if (!mounted) {
            return;
          }

          debugPrint("CERRANDO LOADING DEVOLUCION");

          LoadingDialog.hide();

          if (!mounted) {
            return;
          }

          debugPrint("POP DEVOLUCION");

          Navigator.of(context).pop(true);

          return;
          
     } catch (e) {

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

    } finally {
      debugPrint("FINALLY DEVOLUCION");

    }

  }

  //----------------------------------------------------------
  // Liberar recursos
  //----------------------------------------------------------

  @override
  void dispose() {

    comentariosController.dispose();

    super.dispose();

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
          'Confirmar Devolución',
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
                            //--------------------------------------------------
              // Resumen
              //--------------------------------------------------

              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [

                        Icon(
                          Icons.assignment_return_outlined,
                          color: Colors.orange.shade700,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            '${widget.envios.length} guía(s) seleccionada(s) para devolución',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
                            //--------------------------------------------------
              // Guías
              //--------------------------------------------------

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Guías a devolver (${widget.envios.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  16,
                ),
                itemCount: widget.envios.length,
                separatorBuilder:
                    (_, _) =>
                        const SizedBox(height: 8),
                itemBuilder:
                    (context, index) {

                  final envio =
                      widget.envios[index];

                  final numeroGuia =
                      envio['numero_guia']
                              ?.toString() ??
                          '';

                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_return,
                        color: Colors.orange.shade700,
                      ),
                      title: Text(
                        numeroGuia,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  );

                },
              ),
                            //--------------------------------------------------
              // Motivo
              //--------------------------------------------------

              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12,
                ),
                child: Text(
                  'Motivo de devolución',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [

                      //--------------------------------------------------------
                      // Motivo de devolución
                      //--------------------------------------------------------

                      DropdownButtonFormField<int>(
                        value: idMotivoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Motivo',
                          prefixIcon: Icon(
                            Icons.assignment_return,
                          ),
                          border: OutlineInputBorder(),
                        ),

                        items: catalogoMotivos.map(
                          (motivo) {

                            return DropdownMenuItem<int>(
                              value: motivo['id_devolucion'],
                              child: Text(
                                motivo['descripcion'],
                              ),
                            );

                          },
                        ).toList(),

                        onChanged: (value) {

                          setState(() {

                            idMotivoSeleccionado = value;

                          });

                        },

                        validator: (value) {

                          if (value == null) {

                            return 'Seleccione un motivo de devolución.';

                          }

                          return null;

                        },

                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      //--------------------------------------------------------
                      // Observaciones
                      //--------------------------------------------------------

                      TextFormField(

                        controller:
                            comentariosController,

                        textCapitalization:
                            TextCapitalization.sentences,

                        maxLines: 3,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Observaciones',

                          hintText:
                              'Comentarios adicionales (opcional)',

                          prefixIcon:
                              Icon(Icons.edit_note),

                          border:
                              OutlineInputBorder(),

                        ),

                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
                            //--------------------------------------------------
              // Evidencia fotográfica
              //--------------------------------------------------

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [

                    const Text(
                      'Evidencia fotográfica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (fotoEvidencia != null) ...[

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.file(
                          File(fotoEvidencia!.path),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 10),

                    ],

                    OutlinedButton.icon(
                      onPressed: tomarFoto,
                      icon: Icon(
                        fotoEvidencia == null
                            ? Icons.camera_alt_outlined
                            : Icons.refresh,
                      ),
                      label: Text(
                        fotoEvidencia == null
                            ? 'TOMAR FOTO'
                            : 'VOLVER A TOMAR FOTO',
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 24),
                            Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  24,
                ),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: realizandoDevolucion
                    ? null
                    : realizarDevolucion,
                    icon: const Icon(
                        Icons.assignment_return,
                    ),

                    label: const Text(
                        'REALIZAR DEVOLUCIÓN',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.orange,
                      foregroundColor:
                          Colors.white,
                    ),
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
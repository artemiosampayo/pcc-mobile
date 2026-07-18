/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// entrega_screen.dart
///
/// Carpeta:
/// lib/screens/entrega/
///
/// Sprint:
/// SPR-002
///
/// Historia:
/// HU-008 - Confirmación de Entrega
///
/// Descripción:
///
/// Pantalla para procesar la entrega de una o varias guías
/// seleccionadas desde Mi Ruta.
///
/// En esta primera etapa únicamente recibe y muestra las guías
/// seleccionadas.
///
/// Próximos bloques:
///
/// • Captura de quién recibe.
/// • Evidencia fotográfica.
/// • Firma de recibido.
/// • Confirmación local de la entrega.
/// • Sincronización con PCC.
///
/// ===========================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../core/workflow/workflow_manager.dart';
import '../../services/local/entrega_local_service.dart';


class EntregaScreen extends StatefulWidget {

  const EntregaScreen({
    super.key,
    required this.envios,
  });

  //----------------------------------------------------------
  // Guías seleccionadas para entrega
  //----------------------------------------------------------

  final List<Map<String, dynamic>> envios;

  @override
  State<EntregaScreen> createState() =>
      _EntregaScreenState();

}

class _EntregaScreenState
    extends State<EntregaScreen> {

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final EntregaLocalService entregaLocalService =
      EntregaLocalService.instance;

  //----------------------------------------------------------
  // Estado
  //----------------------------------------------------------

  bool realizandoEntrega = false;
  //----------------------------------------------------------
  // Evidencia fotográfica
  //----------------------------------------------------------

  final ImagePicker imagePicker =
      ImagePicker();

  XFile? fotoEvidencia;

  //----------------------------------------------------------
  // Firma de recibido
  //----------------------------------------------------------

  final SignatureController firmaController =
      SignatureController(
    penStrokeWidth: 3,
  );

  //----------------------------------------------------------
  // Tomar fotografía de evidencia
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
  // Formulario de entrega
  //----------------------------------------------------------

  final TextEditingController
      quienRecibeController =
          TextEditingController();

  final GlobalKey<FormState>
      formKey =
          GlobalKey<FormState>();

  @override
  void dispose() {

    quienRecibeController.dispose();
    firmaController.dispose();

    super.dispose();

  }


//----------------------------------------------------------
// Realizar entrega
//----------------------------------------------------------

Future<void> realizarEntrega() async {

    //--------------------------------------------------------
    // Evitar doble ejecución
    //--------------------------------------------------------

    if (realizandoEntrega) {
      return;
    }

    //--------------------------------------------------------
    // Validar quién recibe
    //--------------------------------------------------------

    if (
        formKey.currentState?.validate() !=
            true
    ) {
      return;
    }

    //--------------------------------------------------------
    // Validar fotografía
    //--------------------------------------------------------

    if (fotoEvidencia == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Debe capturar una fotografía '
            'de evidencia.',
          ),
        ),
      );

      return;

    }

    //--------------------------------------------------------
    // Validar firma
    //--------------------------------------------------------

    if (firmaController.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Debe capturar la firma '
            'de recibido.',
          ),
        ),
      );

      return;

    }

    try {

      //------------------------------------------------------
      // Bloquear procesamiento
      //------------------------------------------------------

      setState(() {
        realizandoEntrega = true;
      });

      //------------------------------------------------------
      // Obtener operación activa
      //------------------------------------------------------

      final operacionActual =
          await WorkflowManager.instance
              .obtenerOperacion();

      if (operacionActual == null) {

        throw Exception(
          'No existe una operación activa.',
        );

      }

      //------------------------------------------------------
      // Validar datos de operación
      //------------------------------------------------------

      if (
          operacionActual.idOperacion == null ||
          operacionActual.idUbicacion == null ||
          operacionActual.idOperador == null ||
          operacionActual.idRuta == null
      ) {

        throw Exception(
          'La operación no contiene todos '
          'los datos requeridos.',
        );

      }

      //------------------------------------------------------
      // Generar PNG de firma
      //------------------------------------------------------

      final firmaBytes =
          await firmaController.toPngBytes();

      if (
          firmaBytes == null ||
          firmaBytes.isEmpty
      ) {

        throw Exception(
          'No fue posible generar la firma '
          'de recibido.',
        );

      }

      //------------------------------------------------------
      // Registrar entrega local
      //------------------------------------------------------

      final resultado =
          await entregaLocalService
              .realizarEntrega(
        idOperacion:
            operacionActual.idOperacion!,

        envios:
            widget.envios,

        quienRecibe:
            quienRecibeController.text,

        fotoOrigenPath:
            fotoEvidencia!.path,

        firmaBytes:
            firmaBytes,

        idUbicacion:
            operacionActual.idUbicacion!,

        idEmpleado:
            operacionActual.idOperador!,

        idRuta:
            operacionActual.idRuta!,
      );

      //------------------------------------------------------
      // Log temporal de diagnóstico
      //------------------------------------------------------

      debugPrint(
        '=================================',
      );

      debugPrint(
        'ENTREGA LOCAL REGISTRADA',
      );

      debugPrint(
        'UUID ENTREGA: '
        '${resultado.uuidEntrega}',
      );

      debugPrint(
        'GUÍAS ENTREGADAS: '
        '${resultado.totalEnvios}',
      );

      debugPrint(
        'MOVIMIENTOS CREADOS: '
        '${resultado.movimientosCreados}',
      );

      debugPrint(
        'FOTO: ${resultado.fotoPath}',
      );

      debugPrint(
        'FIRMA: ${resultado.firmaPath}',
      );


      //------------------------------------------------------
      // Regresar a Mi Ruta
      //------------------------------------------------------

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );

    } catch (e) {

      //------------------------------------------------------
      // Error
      //------------------------------------------------------

      if (!mounted) {
        return;
      }

      setState(() {
        realizandoEntrega = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible realizar '
            'la entrega: $e',
          ),
        ),
      );

    }

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
          'Confirmar Entrega',
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
                          Icons.inventory_2_outlined,
                          color: Colors.green.shade700,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            '${widget.envios.length} '
                            'guía(s) seleccionada(s) '
                            'para entrega',
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
              // Título de guías
              //--------------------------------------------------

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Guías a entregar '
                  '(${widget.envios.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              //--------------------------------------------------
              // Lista de guías
              //--------------------------------------------------

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
                    (context, index) =>
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
                        Icons.check_circle,
                        color: Colors.green.shade700,
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
              // Datos de recepción
              //--------------------------------------------------

              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12,
                ),
                child: Text(
                  'Datos de entrega',
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
                  child: TextFormField(
                    controller:
                        quienRecibeController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration:
                        const InputDecoration(
                      labelText: 'Quién recibe',
                      hintText:
                          'Nombre de la persona que recibe',
                      prefixIcon:
                          Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {

                      if (
                          value == null ||
                          value.trim().isEmpty
                      ) {
                        return 'Ingrese quién recibe.';
                      }

                      return null;

                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                        fontWeight: FontWeight.w600,
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
              const SizedBox(height: 20),

              //--------------------------------------------------
              // Firma de recibido
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
                      'Firma de recibido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Signature(
                        controller: firmaController,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          firmaController.clear();
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        label: const Text(
                          'LIMPIAR FIRMA',
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              //Boton REALIZAR LA ENTREGA
                          const SizedBox(height: 20),

            //--------------------------------------------------
            // Realizar entrega
            //--------------------------------------------------

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
                  onPressed:
                    realizandoEntrega
                        ? null
                        : realizarEntrega,
                 icon:
                    realizandoEntrega
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                          ),

                label: Text(
                  realizandoEntrega
                      ? 'REALIZANDO ENTREGA...'
                      : 'REALIZAR ENTREGA',
                ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade700,
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
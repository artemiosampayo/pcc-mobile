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

      body:

          loading

          ?

          const Center(

            child:
                CircularProgressIndicator(),

          )

          :

          Padding(

            padding:
                const EdgeInsets.all(20),

            child:

                Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Card(

                  child: Padding(

                    padding:
                        const EdgeInsets.all(16),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(

                          "Operación: ${workflow?.idOperacion ?? 0}",

                          style: const TextStyle(

                            fontWeight:
                                FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Ruta: ${workflow?.nombreRuta ?? ""}",
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Operador: ${workflow?.nombreOperador ?? ""}",
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Unidad: ${workflow?.numeroEconomico ?? ""}",
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Contenedor: ${workflow?.contenedor ?? ""}",
                        ),

                      ],

                    ),

                  ),

                ),

              ],

            ),

          ),

    );

  }

}
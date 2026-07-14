/// ===========================================================
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// operation_header.dart
///
/// Carpeta:
/// lib/widgets/
///
/// Descripción:
/// Encabezado reutilizable que muestra el contexto de la
/// operación activa en las pantallas operativas de PCC Mobile.
///
/// Utilizado por:
/// • ECON
/// • Inicio de Ruta
/// • Mi Ruta
/// • Entrega
/// • Devolución
/// ===========================================================

import 'package:flutter/material.dart';

import '../models/workflow_model.dart';

class OperationHeader extends StatelessWidget {
  const OperationHeader({
    super.key,
    required this.workflow,
    this.compact = false,
  });

  final WorkflowModel workflow;

  final bool compact;

  @override
  Widget build(BuildContext context) {
      if (compact) {
        return Card(
          margin: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            4,
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Operador: ',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: _displayValue(
                                workflow.nombreOperador,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: Colors.orange.shade700,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        _displayValue(
                          workflow.nombreRuta,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.orange.shade700,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      _displayValue(
                        workflow.nombreUbicacion,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }


    return Card(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRow(
              Icons.route,
              'Ruta',
              workflow.nombreRuta,
            ),
            const SizedBox(height: 10),
            _buildRow(
              Icons.person,
              'Operador',
              workflow.nombreOperador,
            ),
            const SizedBox(height: 10),
            _buildRow(
              Icons.location_on,
              'Plaza',
              workflow.nombreUbicacion,
            ),
            const SizedBox(height: 10),
            _buildRow(
              Icons.local_shipping,
              'Económico',
              workflow.numeroEconomico,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String label,
    String? value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: _displayValue(value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '—';
    }

    return value;
  }
}
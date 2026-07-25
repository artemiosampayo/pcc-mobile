/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// loading_dialog.dart
///
/// Carpeta:
/// lib/widgets/
///
/// Sprint:
/// SPR-002
///
/// Historia:
/// HU-010 - Loading Dialog Global
///
/// Descripción:
///
/// Diálogo reutilizable para bloquear la interfaz durante
/// operaciones críticas.
///
/// Utilizado por:
///
/// • ECON
/// • Inicio de Ruta
/// • Entrega
/// • Devolución
/// • Finalizar Ruta
/// • Sincronización
///
/// ===========================================================

import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._();

  static bool _visible = false;
  static BuildContext? _dialogContext;

  static Future<void> show(
    BuildContext context, {
    required String message,
  }) async {

    if (_visible) return;

    _dialogContext = null;   // <-- agregar esta línea

    _visible = true;
    try{
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {

            _dialogContext = dialogContext;

            return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),

                    const CircularProgressIndicator(),

                    const SizedBox(height: 24),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Por favor espera...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      );

    }finally {
      if (_dialogContext == null) {
        _visible = false;
      }
    }
    

  
  }

  static void hide() {

    if (!_visible) {
      return;
    }

    if (_dialogContext != null &&
        Navigator.of(
          _dialogContext!,
          rootNavigator: true,
        ).canPop()) {

      Navigator.of(
        _dialogContext!,
        rootNavigator: true,
      ).pop();
    }

    _dialogContext = null;

    _visible = false;
  }
}
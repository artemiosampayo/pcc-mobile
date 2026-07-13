/// ===========================================================
/// PCC Mobile
///
/// Archivo:
/// device_feedback_service.dart
///
/// Carpeta:
/// lib/services/device/
///
/// Sprint:
/// SPR-002
///
/// Issue:
/// ISSUE-003 - Feedback del escáner
///
/// Descripción:
/// Centraliza el feedback auditivo y de vibración para
/// los diferentes resultados del proceso de escaneo.
/// ===========================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class DeviceFeedbackService {
  DeviceFeedbackService._();

  static final DeviceFeedbackService instance =
      DeviceFeedbackService._();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> scanSuccess() async {
    await Vibration.vibrate(
      duration: 120,
    );

    await _playSound(
      'sounds/scan_success.wav',
    );
  }

  Future<void> scanDuplicate() async {
    await Vibration.vibrate(
      pattern: [
        0,
        150,
        100,
        150,
      ],
    );

    await _playSound(
      'sounds/scan_duplicate.wav',
    );
  }

  Future<void> scanError() async {
    await Vibration.vibrate(
      duration: 500,
    );

    await _playSound(
      'sounds/scan_error.wav',
    );
  }

  Future<void> _playSound(
    String asset,
  ) async {
    await _audioPlayer.stop();

    await _audioPlayer.setVolume(
      1.0,
    );

    await _audioPlayer.play(
      AssetSource(asset),
    );
  }
}
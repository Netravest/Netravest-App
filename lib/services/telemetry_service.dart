import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelemetryService {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  final ValueChanged<Map<String, dynamic>> onTelemetryReceived;
  final VoidCallback onConnected;
  final VoidCallback onDisconnected;
  String _currentDeviceCode = '';

  TelemetryService({
    required this.onTelemetryReceived,
    required this.onConnected,
    required this.onDisconnected,
  });

  void connect({String host = '', int port = 0, String deviceCode = ''}) {
    _currentDeviceCode = deviceCode;
    if (_currentDeviceCode.isEmpty) {
      onDisconnected();
      return;
    }

    // Batalkan langganan sebelumnya jika ada
    _subscription?.cancel();

    // Dengarkan dokumen di Firestore secara real-time
    _subscription = FirebaseFirestore.instance
        .collection('telemetri_rompi')
        .doc(_currentDeviceCode)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          onConnected();
          onTelemetryReceived(snapshot.data()!);
        } else {
          // Anggap terhubung (menunggu data pertama dibuat oleh hardware)
          onConnected();
        }
      },
      onError: (error) {
        onDisconnected();
      },
    );
  }

  void publishCommand(Map<String, dynamic> command) {
    if (_currentDeviceCode.isEmpty) {
      return;
    }

    FirebaseFirestore.instance
        .collection('telemetri_rompi')
        .doc(_currentDeviceCode)
        .set({
          'command': command,
          'command_timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  void publishSosStatus(bool active) {
    if (_currentDeviceCode.isEmpty) {
      return;
    }

    FirebaseFirestore.instance
        .collection('telemetri_rompi')
        .doc(_currentDeviceCode)
        .set({
          'sos_active': active,
        }, SetOptions(merge: true));
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    onDisconnected();
  }
}

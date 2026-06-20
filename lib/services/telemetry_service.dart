import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class TelemetryService {
  MqttServerClient? _client;
  final ValueChanged<Map<String, dynamic>> onTelemetryReceived;
  final VoidCallback onConnected;
  final VoidCallback onDisconnected;

  TelemetryService({
    required this.onTelemetryReceived,
    required this.onConnected,
    required this.onDisconnected,
  });

  void connect() async {
    final clientUniqueId = 'netravest_client_${DateTime.now().millisecondsSinceEpoch % 100000}';
    _client = MqttServerClient('broker.hivemq.com', clientUniqueId);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 60;
    _client!.onDisconnected = onDisconnected;
    _client!.onConnected = _onConnectedCallback;
    _client!.logging(on: false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientUniqueId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMess;

    try {
      print('TelemetryService: Menghubungkan ke broker...');
      await _client!.connect();
    } catch (e) {
      print('TelemetryService Connection Error: $e');
      onDisconnected();
    }
  }

  void _onConnectedCallback() {
    print('TelemetryService: Terhubung ke broker');
    onConnected();
    _client!.subscribe('netravest/status', MqttQos.atMostOnce);
    
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payloadStr = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final data = jsonDecode(payloadStr);
        onTelemetryReceived(data);
      } catch (e) {
        print('TelemetryService Parse Error: $e');
      }
    });
  }

  void disconnect() {
    _client?.disconnect();
    onDisconnected();
  }
}

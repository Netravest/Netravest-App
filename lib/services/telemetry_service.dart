import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class TelemetryService {
  MqttServerClient? _client;
  final ValueChanged<Map<String, dynamic>> onTelemetryReceived;
  final VoidCallback onConnected;
  final VoidCallback onDisconnected;
  String _currentDeviceCode = '';

  TelemetryService({
    required this.onTelemetryReceived,
    required this.onConnected,
    required this.onDisconnected,
  });

  void connect({String host = 'broker.hivemq.com', int port = 1883, String deviceCode = ''}) async {
    _currentDeviceCode = deviceCode;
    final clientUniqueId = 'netravest_client_${DateTime.now().millisecondsSinceEpoch % 100000}';
    _client = MqttServerClient(host, clientUniqueId);
    _client!.port = port;
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
    print('TelemetryService: Terhubung ke broker dengan kode $_currentDeviceCode');
    onConnected();
    final topic = _currentDeviceCode.isNotEmpty ? 'netravest/$_currentDeviceCode/status' : 'netravest/status';
    _client!.subscribe(topic, MqttQos.atMostOnce);
    
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

  void publishCommand(Map<String, dynamic> command) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(command));
      final topic = _currentDeviceCode.isNotEmpty ? 'netravest/$_currentDeviceCode/command' : 'netravest/command';
      _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('TelemetryService: Gagal mengirim perintah - klien tidak terhubung.');
    }
  }

  void disconnect() {
    _client?.disconnect();
    onDisconnected();
  }
}

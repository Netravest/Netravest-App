import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/geocoding_service.dart';
import '../services/telemetry_service.dart';
import '../pages/sos_activation_page.dart';
import '../pages/device_login_page.dart';

class EmergencyProvider with ChangeNotifier {
  // Data telemetri dinamis
  String _address = "Mencari lokasi GPS...";
  String _currentTime = '--:--';
  String _currentDate = '--/--/----';
  int _batteryLevel = 0;
  bool _sensorActive = false;
  bool _cameraActive = false;
  bool _isMqttConnected = false;

  double _latitude = 0.0;
  double _longitude = 0.0;

  int _sosTapCount = 0;
  DateTime? _lastSosTapTime;
  bool _isSosActive = false;

  late TelemetryService _telemetryService;

  // Kode Pairing Perangkat
  String _deviceCode = '';
  bool _isConnectingDevice = false;

  // Daftar kontak awal
  bool _isCallExpanded = false;
  bool _isSettingsExpanded = false;
  bool _isDeviceExpanded = false;
  int _sosTapThreshold = 5;
  int _recordingDuration = 30;
  String _mqttHost = 'broker.hivemq.com';
  int _mqttPort = 1883;
  bool _isSimulationActive = false;
  Timer? _simulationTimer;
  bool _isLeftHanded = false;

  final List<Map<String, String>> _contacts = [
    {'name': 'Polisi', 'phone': '110'},
    {'name': 'Ambulans', 'phone': '118'},
  ];

  final bool _enableMqtt;

  EmergencyProvider({this._enableMqtt = true}) {
    // Inisialisasi Telemetry Service
    _telemetryService = TelemetryService(
      onTelemetryReceived: _updateTelemetry,
      onConnected: () {
        if (_isSimulationActive) return;
        _isMqttConnected = true;
        notifyListeners();
      },
      onDisconnected: () {
        if (_isSimulationActive) return;
        _isMqttConnected = false;
        notifyListeners();
      },
    );
    // Memulai koneksi MQTT jika deviceCode sudah ada (belum ada pada start)
    if (_enableMqtt && _deviceCode.isNotEmpty) {
      connectToMQTT();
    }
  }

  // Getter data ke UI
  String get address => _address;
  String get currentTime => _currentTime;
  String get currentDate => _currentDate;
  int get batteryLevel => _batteryLevel;
  bool get isSensorActive => _sensorActive;
  bool get isCameraActive => _cameraActive;
  bool get isMqttConnected => _isMqttConnected;
  bool get isCallExpanded => _isCallExpanded;
  bool get isSettingsExpanded => _isSettingsExpanded;
  bool get isDeviceExpanded => _isDeviceExpanded;
  int get sosTapThreshold => _sosTapThreshold;
  int get recordingDuration => _recordingDuration;
  String get mqttHost => _mqttHost;
  int get mqttPort => _mqttPort;
  bool get isSimulationActive => _isSimulationActive;
  bool get isSosActive => _isSosActive;
  bool get isLeftHanded => _isLeftHanded;
  List<Map<String, String>> get contacts => List.from(_contacts);
  bool get canAddContact => _contacts.length < 5;
  String get deviceCode => _deviceCode;
  bool get isConnectingDevice => _isConnectingDevice;

  void toggleCallExpansion() {
    _isCallExpanded = !_isCallExpanded;
    if (_isCallExpanded) {
      _isSettingsExpanded = false;
      _isDeviceExpanded = false;
    }
    notifyListeners();
  }

  void toggleSettingsExpansion() {
    _isSettingsExpanded = !_isSettingsExpanded;
    if (_isSettingsExpanded) {
      _isCallExpanded = false;
      _isDeviceExpanded = false;
    }
    notifyListeners();
  }

  void toggleDeviceExpansion() {
    _isDeviceExpanded = !_isDeviceExpanded;
    if (_isDeviceExpanded) {
      _isCallExpanded = false;
      _isSettingsExpanded = false;
    }
    notifyListeners();
  }

  void setSosTapThreshold(int val) {
    _sosTapThreshold = val;
    notifyListeners();
  }

  void toggleLeftHanded(bool val) {
    _isLeftHanded = val;
    notifyListeners();
  }

  void setRecordingDuration(int val) {
    _recordingDuration = val;
    notifyListeners();
  }

  void updateMqttConfig(String host, int port) {
    _mqttHost = host;
    _mqttPort = port;
    notifyListeners();
    // Reconnect with new configuration if simulation is not active
    if (!_isSimulationActive) {
      disconnectMQTT();
      connectToMQTT();
    }
  }

  void resetSettings() {
    _sosTapThreshold = 5;
    _recordingDuration = 30;
    _mqttHost = 'broker.hivemq.com';
    _mqttPort = 1883;
    _isLeftHanded = false;
    if (_isSimulationActive) {
      toggleSimulation(false);
    } else {
      disconnectMQTT();
      connectToMQTT();
    }
    notifyListeners();
  }

  void toggleSimulation(bool value) {
    if (_isSimulationActive == value) return;
    _isSimulationActive = value;
    if (_isSimulationActive) {
      // Disconnect MQTT if connected
      disconnectMQTT();
      _isMqttConnected = true; // Show simulated connection status

      // Start Simulation Timer
      _simulationTimer?.cancel();
      _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        // Mock current time
        final now = DateTime.now();
        _currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
        _currentDate =
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

        // Mock battery level (oscillating or slowly decreasing and resetting)
        _batteryLevel = (_batteryLevel - 1) % 100;
        if (_batteryLevel <= 0) _batteryLevel = 100;

        // Mock sensor status (toggle every 8 seconds)
        if (timer.tick % 2 == 0) {
          _sensorActive = !_sensorActive;
        }
        // Mock camera status (toggle every 12 seconds)
        if (timer.tick % 3 == 0) {
          _cameraActive = !_cameraActive;
        }

        // Walk GPS coordinates slightly
        if (_latitude == 0.0) {
          _latitude = -6.2088;
          _longitude = 106.8456;
        } else {
          // Walk by adding tiny random value
          final randomOffsetLat = (timer.tick % 5 - 2) * 0.0001;
          final randomOffsetLng = (timer.tick % 7 - 3) * 0.0001;
          _latitude += randomOffsetLat;
          _longitude += randomOffsetLng;
        }

        _triggerGeocoding(_latitude, _longitude);
        notifyListeners();
      });
    } else {
      _simulationTimer?.cancel();
      _simulationTimer = null;
      _isMqttConnected = false;
      // Reconnect MQTT
      connectToMQTT();
    }
    notifyListeners();
  }

  void addContact(String name, String phone) {
    if (_contacts.length >= 5) return;
    _contacts.add({'name': name, 'phone': phone});
    notifyListeners();
  }

  void deleteContact(int index) {
    if (index >= 0 && index < _contacts.length) {
      _contacts.removeAt(index);
      notifyListeners();
    }
  }

  void handleSosTap(BuildContext context) {
    final now = DateTime.now();
    if (_lastSosTapTime == null ||
        now.difference(_lastSosTapTime!) > const Duration(seconds: 3)) {
      _sosTapCount = 1;
      _lastSosTapTime = now;
    } else {
      _sosTapCount++;
    }

    if (_sosTapCount >= _sosTapThreshold) {
      _triggerFullEmergency(context);
      _sosTapCount = 0;
      _lastSosTapTime = null;
    } else {
      showPopupSnackBar(
        context,
        '⚠️ Tekan $_sosTapCount/$_sosTapThreshold kali untuk SOS!',
        Colors.orange,
      );
    }
  }

  void _triggerFullEmergency(BuildContext context) {
    _isSosActive = true;
    notifyListeners();

    // 1. Kirim perintah perekaman ke Raspberry Pi
    _telemetryService.publishCommand({
      'action': 'start_recording',
      'duration': _recordingDuration,
    });

    // 2. Hubungi dan kirim lokasi ke rekan terdekat sekaligus via WhatsApp
    if (_contacts.isNotEmpty) {
      final nearestContact = _contacts.last;
      final phone = nearestContact['phone'];
      final name = nearestContact['name'];

      if (phone != null) {
        var cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

        if (cleanPhone.length > 5) {
          // Format ke kode negara (ganti 0 dengan 62)
          if (cleanPhone.startsWith('0')) {
            cleanPhone = '62${cleanPhone.substring(1)}';
          }

          showPopupSnackBar(
            context,
            '🚨 Mengirim lokasi ke $name via WhatsApp...',
            Colors.red,
          );

          // Gabungkan: chat personal + teks pesan berisi Google Maps link
          final textMessage = Uri.encodeComponent(
            'SOS! Saya membutuhkan bantuan segera. Lokasi GPS saya: https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude',
          );
          final waUrl = Uri.parse(
            'https://wa.me/$cleanPhone?text=$textMessage',
          );
          _launchURL(context, waUrl);
        } else {
          // Jika nomor pendek (seperti 110), lakukan panggilan seluler biasa
          final telUrl = Uri.parse('tel:$cleanPhone');
          _launchURL(context, telUrl);
        }
      }
    } else {
      // Jika tidak ada kontak, kirim SOS umum (memilih kontak manual di WhatsApp)
      sendSOS(context);
    }

    // 3. Navigasi ke halaman SOS Aktif secara Full Screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SosActivationPage()),
    );
  }

  void cancelSos(BuildContext context) {
    _isSosActive = false;
    notifyListeners();
    Navigator.pop(context); // Menutup halaman SOS Full Screen
  }

  void showPopupSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // Delegasi koneksi MQTT ke TelemetryService
  void connectToMQTT() {
    if (!_enableMqtt || _isSimulationActive) return;
    _telemetryService.connect(
      host: _mqttHost,
      port: _mqttPort,
      deviceCode: _deviceCode,
    );
  }

  void disconnectMQTT() {
    if (!_enableMqtt) return;
    _telemetryService.disconnect();
  }

  Future<bool> connectDevice(String code, {bool simulate = false}) async {
    _isConnectingDevice = true;
    notifyListeners();

    // Jeda loading estetik
    await Future.delayed(const Duration(milliseconds: 1500));

    _deviceCode = code.trim().toUpperCase();
    _isConnectingDevice = false;

    if (simulate) {
      _isSimulationActive = true;
      _isMqttConnected = true;
      toggleSimulation(true);
      notifyListeners();
      return true;
    }

    _isSimulationActive = false;
    connectToMQTT();
    notifyListeners();
    return true;
  }

  void disconnectDevice() {
    _deviceCode = '';
    _isMqttConnected = false;
    _isDeviceExpanded = false;
    if (_isSimulationActive) {
      toggleSimulation(false);
    } else {
      disconnectMQTT();
    }
    notifyListeners();
  }

  void _updateTelemetry(Map<String, dynamic> data) {
    if (_isSimulationActive) return;
    if (data.containsKey('battery')) {
      _batteryLevel = data['battery'] as int;
    }
    if (data.containsKey('sensor_active')) {
      _sensorActive = data['sensor_active'] as bool;
    }
    if (data.containsKey('camera_active')) {
      _cameraActive = data['camera_active'] as bool;
    }
    if (data.containsKey('timestamp')) {
      _currentTime = data['timestamp'] as String;
    }

    final now = DateTime.now();
    _currentDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // Update GPS & Alamat
    if (data.containsKey('latitude') && data.containsKey('longitude')) {
      final newLat = (data['latitude'] as num).toDouble();
      final newLng = (data['longitude'] as num).toDouble();

      // Update alamat jika koordinat bergeser signifikan
      if ((newLat - _latitude).abs() > 0.0001 ||
          (newLng - _longitude).abs() > 0.0001 ||
          _address == "Mencari lokasi GPS...") {
        _latitude = newLat;
        _longitude = newLng;
        _triggerGeocoding(newLat, newLng);
      }
    }
    notifyListeners();
  }

  // Pemicu Geocoding via GeocodingService
  void _triggerGeocoding(double lat, double lng) async {
    final result = await GeocodingService.reverseGeocode(lat, lng);
    if (result != null) {
      _address = _isSimulationActive ? '$result (Simulasi)' : result;
    } else {
      _address =
          'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}${_isSimulationActive ? ' (Simulasi)' : ''}';
    }
    notifyListeners();
  }

  // Kirim SOS dan Lokasi Google Maps via WhatsApp
  void sendSOS(BuildContext context) {
    if (_latitude == 0.0 && _longitude == 0.0) {
      showPopupSnackBar(
        context,
        '⚠️ SOS Gagal: Lokasi GPS belum didapatkan!',
        Colors.red,
      );
      return;
    }
    showPopupSnackBar(
      context,
      '⚠️ Mengirim pesan SOS via WhatsApp...',
      Colors.red,
    );
    final url = Uri.parse(
      'https://wa.me/?text=SOS! Saya membutuhkan bantuan. Lokasi saya: https://www.google.com/maps/search/?api=1%26query=$_latitude,$_longitude',
    );
    _launchURL(context, url);
  }

  void copyAddress(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _address));
    showPopupSnackBar(context, '📍 Alamat disalin!', Colors.deepOrange);
  }

  void shareLocation(BuildContext context) {
    if (_latitude == 0.0 && _longitude == 0.0) {
      showPopupSnackBar(context, '📍 Lokasi GPS belum siap!', Colors.red);
      return;
    }
    final url = Uri.parse(
      'https://wa.me/?text=Lokasi saya: https://www.google.com/maps/search/?api=1%26query=$_latitude,$_longitude',
    );
    _launchURL(context, url);
  }

  // Meluncurkan Telepon (WhatsApp atau Seluler)
  void makeCall(BuildContext context, {String? name, String? phone}) {
    if (phone == null) return;

    var cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Jika nomor darurat pendek, gunakan panggilan telepon biasa
    if (cleanPhone.length <= 5) {
      final telUrl = Uri.parse('tel:$cleanPhone');
      _launchURL(context, telUrl);
      return;
    }

    // Format nomor WhatsApp berawalan 62
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }

    final waUrl = Uri.parse('https://wa.me/$cleanPhone');
    _launchURL(context, waUrl);
  }

  void refreshStatus(BuildContext context) {
    showPopupSnackBar(
      context,
      '🔄 Menyambungkan ulang ke Rompi...',
      Colors.blue,
    );
    disconnectMQTT();
    connectToMQTT();
  }

  void openSettings(BuildContext context) {
    showPopupSnackBar(context, '⚙️ Pengaturan...', Colors.grey);
  }

  void toggleFloatingWidget(BuildContext context) {
    // Tombol kosong / Tidak terjadi apa-apa
  }

  void manageDevice(BuildContext context) {
    if (deviceCode.isNotEmpty) {
      toggleDeviceExpansion();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DeviceLoginPage()),
      );
    }
  }

  Future<void> _launchURL(BuildContext context, Uri url) async {
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        showPopupSnackBar(context, '⚠️ Gagal membuka aplikasi!', Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        showPopupSnackBar(context, 'Error: $e', Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    super.dispose();
  }
}

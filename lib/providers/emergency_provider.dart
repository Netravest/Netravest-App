import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/geocoding_service.dart';
import '../services/telemetry_service.dart';

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

  late TelemetryService _telemetryService;

  // Daftar kontak awal
  bool _isCallExpanded = false;
  final List<Map<String, String>> _contacts = [
    {'name': 'Bile Bondol', 'phone': '0812-3456-7890'},
    {'name': 'Polisi', 'phone': '110'},
    {'name': 'Ambulans', 'phone': '118'},
  ];

  EmergencyProvider() {
    // Inisialisasi Telemetry Service
    _telemetryService = TelemetryService(
      onTelemetryReceived: _updateTelemetry,
      onConnected: () {
        _isMqttConnected = true;
        notifyListeners();
      },
      onDisconnected: () {
        _isMqttConnected = false;
        notifyListeners();
      },
    );
    // Memulai koneksi MQTT ketika aplikasi berjalan
    connectToMQTT();
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
  List<Map<String, String>> get contacts => List.from(_contacts);

  void toggleCallExpansion() {
    _isCallExpanded = !_isCallExpanded;
    notifyListeners();
  }

  void addContact(String name, String phone) {
    _contacts.add({'name': name, 'phone': phone});
    notifyListeners();
  }

  void deleteContact(int index) {
    if (index >= 0 && index < _contacts.length) {
      _contacts.removeAt(index);
      notifyListeners();
    }
  }

  void showPopupSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // Delegasi koneksi MQTT ke TelemetryService
  void connectToMQTT() {
    _telemetryService.connect();
  }

  void disconnectMQTT() {
    _telemetryService.disconnect();
  }

  void _updateTelemetry(Map<String, dynamic> data) {
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
    _currentDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // Update GPS & Alamat
    if (data.containsKey('latitude') && data.containsKey('longitude')) {
      final newLat = (data['latitude'] as num).toDouble();
      final newLng = (data['longitude'] as num).toDouble();
      
      // Update alamat jika koordinat bergeser signifikan
      if ((newLat - _latitude).abs() > 0.0001 || (newLng - _longitude).abs() > 0.0001 || _address == "Mencari lokasi GPS...") {
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
      _address = result;
    } else {
      _address = 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
    }
    notifyListeners();
  }

  // Kirim SOS dan Lokasi Google Maps via WhatsApp
  void sendSOS(BuildContext context) {
    if (_latitude == 0.0 && _longitude == 0.0) {
      showPopupSnackBar(context, '⚠️ SOS Gagal: Lokasi GPS belum didapatkan!', Colors.red);
      return;
    }
    showPopupSnackBar(context, '⚠️ Mengirim pesan SOS via WhatsApp...', Colors.red);
    final url = Uri.parse('https://wa.me/?text=SOS! Saya membutuhkan bantuan. Lokasi saya: https://www.google.com/maps/search/?api=1%26query=$_latitude,$_longitude');
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
    final url = Uri.parse('https://wa.me/?text=Lokasi saya: https://www.google.com/maps/search/?api=1%26query=$_latitude,$_longitude');
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
    
    final target = name ?? phone;
    showPopupSnackBar(context, '📞 Menghubungi $target via WhatsApp...', Colors.green);
    final waUrl = Uri.parse('https://wa.me/$cleanPhone');
    _launchURL(context, waUrl);
  }

  void refreshStatus(BuildContext context) {
    showPopupSnackBar(context, '🔄 Menyambungkan ulang ke Rompi...', Colors.blue);
    disconnectMQTT();
    connectToMQTT();
  }

  void openSettings(BuildContext context) {
    showPopupSnackBar(context, '⚙️ Pengaturan...', Colors.grey);
  }

  void toggleFloatingWidget(BuildContext context) {
    showPopupSnackBar(context, '📱 Widget Mengambang...', Colors.deepOrange);
  }

  void manageDevice(BuildContext context) {
    showPopupSnackBar(context, '🛡️ Menu Perangkat...', Colors.grey);
  }

  Future<void> _launchURL(BuildContext context, Uri url) async {
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        showPopupSnackBar(context, '⚠️ Gagal membuka aplikasi!', Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        showPopupSnackBar(context, 'Error: $e', Colors.red);
      }
    }
  }
}

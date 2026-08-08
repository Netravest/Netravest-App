import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/openstreetmap_service.dart';
import '../services/telemetry_service.dart';
import '../pages/sos_activation_page.dart';
import '../pages/device_login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyProvider with ChangeNotifier {
  // Data telemetri dinamis
  String _address = "Mencari lokasi GPS...";
  String _currentTime = '--:--';
  String _currentDate = '--/--/----';
  int _batteryLevel = 0;
  bool _sensorActive = false;
  bool _cameraActive = false;
  bool _isGpsModuleActive = false;
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
  String _userRole = 'tunanetra'; // 'tunanetra' atau 'pendamping'

  // Daftar kontak awal
  bool _isCallExpanded = false;
  bool _isSettingsExpanded = false;
  bool _isDeviceExpanded = false;
  int _sosTapThreshold = 5;
  int _recordingDuration = 30;
  String _mqttHost = 'Google Cloud Firestore';
  int _mqttPort = 443;
  bool _isSimulationActive = false;
  Timer? _simulationTimer;
  bool _isLeftHanded = false;
  bool _usePhoneGps = false;
  StreamSubscription<Position>? _gpsSubscription;

  final List<Map<String, String>> _contacts = [
    {'name': 'Polisi', 'phone': '110'},
    {'name': 'Ambulans', 'phone': '118'},
  ];

  final bool _enableMqtt;

  // ignore: prefer_initializing_formals
  EmergencyProvider({bool enableMqtt = true}) : _enableMqtt = enableMqtt {
    _startLocalClock();
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
    // Memulai koneksi telemetri jika deviceCode sudah ada (belum ada pada start)
    if (_enableMqtt && _deviceCode.isNotEmpty) {
      connectToTelemetry();
    }
  }

  // Getter data ke UI
  String get address => _address;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get currentTime => _currentTime;
  String get currentDate => _currentDate;
  int get batteryLevel => _batteryLevel;
  bool get isSensorActive => _sensorActive;
  bool get isCameraActive => _cameraActive;
  bool get isGpsModuleActive => _isGpsModuleActive;
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
  bool get usePhoneGps => _usePhoneGps;
  List<Map<String, String>> get contacts => List.from(_contacts);
  bool get canAddContact => _contacts.length < 5;
  String get deviceCode => _deviceCode;
  bool get isConnectingDevice => _isConnectingDevice;
  String get userRole => _userRole;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

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

  Future<void> toggleUsePhoneGps(bool value, BuildContext context) async {
    _usePhoneGps = value;
    notifyListeners();

    if (_usePhoneGps) {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _usePhoneGps = false;
        notifyListeners();
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Layanan Lokasi Mati', style: TextStyle(color: Colors.white)),
            content: const Text('Silakan aktifkan layanan lokasi (GPS) pada perangkat Anda.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 255, 74, 0))),
              ),
            ],
          ),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _usePhoneGps = false;
          notifyListeners();
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Izin Ditolak', style: TextStyle(color: Colors.white)),
              content: const Text('Aplikasi memerlukan izin lokasi untuk menggunakan GPS Handphone.', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 255, 74, 0))),
                ),
              ],
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _usePhoneGps = false;
        notifyListeners();
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Izin Ditolak Permanen', style: TextStyle(color: Colors.white)),
            content: const Text('Izin lokasi ditolak secara permanen. Silakan aktifkan izin lokasi di pengaturan aplikasi ponsel Anda.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 255, 74, 0))),
              ),
            ],
          ),
        );
        return;
      }

      _gpsSubscription?.cancel();
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _latitude = position.latitude;
        _longitude = position.longitude;
        _triggerGeocoding(_latitude, _longitude);

        if (_deviceCode.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('telemetri_rompi')
              .doc(_deviceCode)
              .set({
                'AlamatLokasi': _address,
                'LongLatLokasi': GeoPoint(_latitude, _longitude),
                'Timestamp': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error getting initial position: $e');
      }

      _gpsSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        if (_usePhoneGps) {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _triggerGeocoding(_latitude, _longitude);

          if (_deviceCode.isNotEmpty) {
            FirebaseFirestore.instance
                .collection('telemetri_rompi')
                .doc(_deviceCode)
                .set({
                  'AlamatLokasi': _address,
                  'LongLatLokasi': GeoPoint(_latitude, _longitude),
                  'Timestamp': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
          }
          notifyListeners();
        }
      }, onError: (error) {
        debugPrint('Geolocator stream error: $error');
      });
    } else {
      _gpsSubscription?.cancel();
      _gpsSubscription = null;
      notifyListeners();
      
      if (_deviceCode.isNotEmpty) {
        refreshStatus(context);
      }
    }
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
      disconnectTelemetry();
      connectToTelemetry();
    }
  }

  void resetSettings() {
    _sosTapThreshold = 5;
    _recordingDuration = 30;
    _mqttHost = 'Google Cloud Firestore';
    _mqttPort = 443;
    _isLeftHanded = false;
    _usePhoneGps = false;
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    if (_isSimulationActive) {
      toggleSimulation(false);
    } else {
      disconnectTelemetry();
      connectToTelemetry();
    }
    notifyListeners();
  }

  void toggleSimulation(bool value) {
    if (_isSimulationActive == value) return;
    _isSimulationActive = value;
    if (_isSimulationActive) {
      // Disconnect Telemetry if connected
      disconnectTelemetry();
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

        // Kirim data simulasi ke Firestore agar pendamping bisa memantau secara real-time
        if (_deviceCode.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('telemetri_rompi')
              .doc(_deviceCode)
              .set({
                'AlamatLokasi': _address,
                'PersentaseBaterai': _batteryLevel,
                'StatusKamera': _cameraActive,
                'StatusLidar': _sensorActive,
                'sos_active': _isSosActive,
                'LongLatLokasi': GeoPoint(_latitude, _longitude),
                'Timestamp': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }

        _triggerGeocoding(_latitude, _longitude);
        notifyListeners();
      });
    } else {
      _simulationTimer?.cancel();
      _simulationTimer = null;
      _isMqttConnected = false;
      // Reconnect Telemetry
      connectToTelemetry();
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

    // Kirim status SOS aktif ke Firestore agar pendamping mengetahuinya secara real-time
    _telemetryService.publishSosStatus(true);

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
    // Kirim status SOS mati ke Firestore agar pendamping mengetahuinya secara real-time
    _telemetryService.publishSosStatus(false);
  }

  void toggleSos() {
    _isSosActive = !_isSosActive;
    notifyListeners();
    _telemetryService.publishSosStatus(_isSosActive);
  }

  void showPopupSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    // Dinonaktifkan untuk menghilangkan seluruh notifikasi SnackBar di bawah
  }

  // Delegasi koneksi telemetri ke TelemetryService
  void connectToTelemetry() {
    if (!_enableMqtt || _isSimulationActive) return;
    _telemetryService.connect(
      host: _mqttHost,
      port: _mqttPort,
      deviceCode: _deviceCode,
    );
  }

  void disconnectTelemetry() {
    if (!_enableMqtt) return;
    _telemetryService.disconnect();
  }

  Future<bool> connectDevice(String code, {bool simulate = false}) async {
    _isConnectingDevice = true;
    notifyListeners();

    // Jeda loading estetik
    await Future.delayed(const Duration(milliseconds: 1500));

    _deviceCode = code.trim().toUpperCase();
    _resetTelemetryData();
    _isConnectingDevice = false;

    if (simulate) {
      _isSimulationActive = true;
      _isMqttConnected = true;
      _telemetryService.connect(deviceCode: _deviceCode);
      toggleSimulation(true);
      notifyListeners();
      return true;
    }

    // Lakukan login anonim jika pengguna belum terautentikasi (agar bisa lolos aturan keamanan Firestore)
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {
        // Gagal login anonim, lanjutkan tanpa auth kustom
      }
    }

    _isSimulationActive = false;
    connectToTelemetry();
    notifyListeners();
    return true;
  }

  void disconnectDevice() {
    _deviceCode = '';
    _isMqttConnected = false;
    _isDeviceExpanded = false;
    _resetTelemetryData();
    if (_isSimulationActive) {
      toggleSimulation(false);
    } else {
      disconnectTelemetry();
    }
    notifyListeners();
  }

  void _resetTelemetryData() {
    _address = "Mencari lokasi GPS...";
    _currentTime = '--:--';
    _currentDate = '--/--/----';
    _batteryLevel = 0;
    _sensorActive = false;
    _cameraActive = false;
    _latitude = 0.0;
    _longitude = 0.0;
    _isSosActive = false;
  }

  void _startLocalClock() {
    _updateLocalClock();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateLocalClock();
    });
  }

  void _updateLocalClock() {
    final now = DateTime.now();
    _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _currentDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    notifyListeners();
  }

  void _updateTelemetry(Map<String, dynamic> data) {
    if (_isSimulationActive) {
      // Jika simulasi aktif, kita tetap ingin mensinkronkan status SOS dari Firestore
      // agar jika pendamping meresolusi/mematikan SOS, simulator ikut terupdate.
      if (data.containsKey('sos_active')) {
        final extSos = data['sos_active'] as bool;
        if (_isSosActive != extSos) {
          _isSosActive = extSos;
          notifyListeners();
        }
      }
      return;
    }

    if (data.containsKey('PersentaseBaterai')) {
      _batteryLevel = (data['PersentaseBaterai'] as num).toInt();
    }
    if (data.containsKey('StatusLidar')) {
      _sensorActive = data['StatusLidar'] as bool;
    }
    if (data.containsKey('StatusKamera')) {
      _cameraActive = data['StatusKamera'] as bool;
    }
    if (data.containsKey('StatusGPS')) {
      _isGpsModuleActive = data['StatusGPS'] as bool;
    }

    if (data.containsKey('sos_active')) {
      _isSosActive = data['sos_active'] as bool;
    }
    if (data.containsKey('AlamatLokasi') && (data['AlamatLokasi'] as String).isNotEmpty) {
      _address = data['AlamatLokasi'] as String;
    }

    // Update GPS & Alamat
    if (data.containsKey('LongLatLokasi')) {
      final geoVal = data['LongLatLokasi'];
      if (geoVal is GeoPoint) {
        final newLat = geoVal.latitude;
        final newLng = geoVal.longitude;

        // Update alamat jika koordinat bergeser signifikan
        if ((newLat - _latitude).abs() > 0.0001 ||
            (newLng - _longitude).abs() > 0.0001 ||
            _address == "Mencari lokasi GPS...") {
          _latitude = newLat;
          _longitude = newLng;
          
          if (!data.containsKey('AlamatLokasi') || (data['AlamatLokasi'] as String).isEmpty) {
            _triggerGeocoding(newLat, newLng);
          }
        }
      }
    }
    notifyListeners();
  }

  // Pemicu Geocoding via OpenStreetMapService
  void _triggerGeocoding(double lat, double lng) async {
    final result = await OpenStreetMapService.reverseGeocode(lat, lng);
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

  void openMapLocation(BuildContext context) {
    if (_latitude == 0.0 && _longitude == 0.0) {
      showPopupSnackBar(context, '📍 Lokasi GPS belum siap!', Colors.red);
      return;
    }
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude',
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

  void refreshStatus(BuildContext context) async {
    showPopupSnackBar(
      context,
      '🔄 Mengambil data terbaru dari Firebase...',
      Colors.blue,
    );
    
    // Sambungkan ulang listener secara real-time
    disconnectTelemetry();
    connectToTelemetry();

    // Lakukan paksaan pengambilan data dari server cloud Firestore secara langsung
    if (_deviceCode.isNotEmpty) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('telemetri_rompi')
            .doc(_deviceCode)
            .get(const GetOptions(source: Source.server));
            
        if (docSnapshot.exists && docSnapshot.data() != null) {
          _updateTelemetry(docSnapshot.data()!);
        }
      } catch (e) {
        // Gagal mengambil data secara langsung (offline/masalah jaringan)
      }
    }
  }

  void openSettings(BuildContext context) {
    showPopupSnackBar(context, '⚙️ Pengaturan...', Colors.grey);
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

  Future<void> completeTutorial(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'hasCompletedTutorial': true});
    } catch (e) {
      debugPrint('Error completing tutorial: $e');
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    super.dispose();
  }
}

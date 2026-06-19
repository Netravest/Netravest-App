import 'package:flutter/material.dart';

class EmergencyProvider with ChangeNotifier {
  final String _address = "Jln. Lorem Ipsum No 013,\nKec. Dolor SitAmet";
  final String _currentTime = '23:20';
  final String _currentDate = '19/01/2026';
  final int _batteryLevel = 100;
  final bool _SensorActive = true;
  final bool _cameraActive = true;

  // Getter
  String get address => _address;
  String get currentTime => _currentTime;
  String get currentDate => _currentDate;
  int get batteryLevel => _batteryLevel;
  bool get isSensorActive => _SensorActive;
  bool get isCameraActive => _cameraActive;

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

  void sendSOS(BuildContext context) {
    showPopupSnackBar(
      context,
      '⚠️ SOS DIKIRIM! Menghubungi pusat bantuan...',
      Colors.red,
    );
  }

  void copyAddress(BuildContext context) {
    showPopupSnackBar(
      context,
      '📍 Alamat disalin ke clipboard!',
      Colors.deepOrange,
    );
  }

  void shareLocation(BuildContext context) {
    showPopupSnackBar(
      context,
      '📤 Membagikan lokasi GPS Anda...',
      Colors.black,
    );
  }

  void makeCall(BuildContext context) {
    showPopupSnackBar(
      context,
      '📞 Menghubungi layanan darurat...',
      Colors.green,
    );
  }

  void refreshStatus(BuildContext context) {
    showPopupSnackBar(context, '🔄 Memperbarui status darurat...', Colors.blue);
    notifyListeners();
  }

    void openSettings(BuildContext context) {
    showPopupSnackBar(context, '⚙️ Membuka Pengaturan aplikasi...', Colors.grey);
  }

    void toggleFloatingWidget(BuildContext context) {
    showPopupSnackBar(context, '📱 Mengaktifkan Widget Mengambang...', Colors.deepOrange);
  }

 void manageDevice(BuildContext context) {
    showPopupSnackBar(context, '🛡️ Membuka menu kelola Perangkat...', Colors.grey);
  }
}

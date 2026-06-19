import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    
    // Mengamati data spesifik menggunakan context.select agar widget tidak ter-rebuild tidak penting
    final time = context.select((EmergencyProvider p) => p.currentTime);
    final date = context.select((EmergencyProvider p) => p.currentDate);
    final battery = context.select((EmergencyProvider p) => p.batteryLevel);

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => provider.showPopupSnackBar(
              context, '⏰ Waktu saat ini: $time | Tanggal: $date', Colors.blueGrey,
            ),
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSmallGreenIcon(
                Icons.sensors,
                onTap: () => provider.showPopupSnackBar(
                  context, '📡 Sensor aktif dan memantau status...', Colors.green,
                ),
              ),
              _buildSmallGreenIcon(
                Icons.camera_alt_rounded,
                onTap: () => provider.showPopupSnackBar(
                  context, '📷 Akses kamera darurat aktif...', Colors.green,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => provider.showPopupSnackBar(
              context, '🔋 Baterai perangkat terisi penuh ($battery%)', Colors.green,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 255, 42),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '$battery%',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => provider.refreshStatus(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 74, 0),
                borderRadius: BorderRadius.circular(45),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.black, size: 80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallGreenIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 255, 42),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.black, size: 50),
      ),
    );
  }
}

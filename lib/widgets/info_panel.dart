import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    
    final time = context.select((EmergencyProvider p) => p.currentTime);
    final date = context.select((EmergencyProvider p) => p.currentDate);
    final battery = context.select((EmergencyProvider p) => p.batteryLevel);
    final isSensorActive = context.select((EmergencyProvider p) => p.isSensorActive);
    final isCameraActive = context.select((EmergencyProvider p) => p.isCameraActive);
    final isMqttConnected = context.select((EmergencyProvider p) => p.isMqttConnected);

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 8, right: 10, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => provider.showPopupSnackBar(
              context, '⏰ Waktu: $time | Tanggal: $date', Colors.blueGrey,
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
                const SizedBox(height: 4),
                // Indikator Koneksi MQTT ke Rompi
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isMqttConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMqttConnected ? 'ROMPI ONLINE' : 'ROMPI OFFLINE',
                      style: TextStyle(
                        color: isMqttConnected ? Colors.green[800] : Colors.red[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Indikator Status Sensor LiDAR
              _buildStatusIcon(
                Icons.sensors,
                isActive: isSensorActive,
                onTap: () => provider.showPopupSnackBar(
                  context,
                  isSensorActive ? '📡 Sensor LiDAR Aktif.' : '📡 Sensor LiDAR Mati.',
                  isSensorActive ? Colors.green : Colors.red,
                ),
              ),
              // Indikator Status Kamera
              _buildStatusIcon(
                Icons.camera_alt_rounded,
                isActive: isCameraActive,
                onTap: () => provider.showPopupSnackBar(
                  context,
                  isCameraActive ? '📷 Kamera Aktif.' : '📷 Kamera Mati.',
                  isCameraActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Persentase Baterai
          GestureDetector(
            onTap: () => provider.showPopupSnackBar(
              context, '🔋 Baterai Rompi: $battery%', Colors.green,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isMqttConnected ? const Color.fromARGB(255, 0, 255, 42) : Colors.grey[400],
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
          const SizedBox(height: 5),
          // Tombol Hubungkan Ulang (Refresh)
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

  Widget _buildStatusIcon(IconData icon, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color.fromARGB(255, 0, 255, 42) : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.grey[700],
          size: 50,
        ),
      ),
    );
  }
}

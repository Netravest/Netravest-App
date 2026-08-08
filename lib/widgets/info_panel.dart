import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import 'animated_pressable.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();

    final time = context.select((EmergencyProvider p) => p.currentTime);
    final date = context.select((EmergencyProvider p) => p.currentDate);
    final battery = context.select((EmergencyProvider p) => p.batteryLevel);
    final isSensorActive = context.select(
      (EmergencyProvider p) => p.isSensorActive,
    );
    final isCameraActive = context.select(
      (EmergencyProvider p) => p.isCameraActive,
    );
    final isMqttConnected = context.select(
      (EmergencyProvider p) => p.isMqttConnected,
    );
    final isGpsModuleActive = context.select(
      (EmergencyProvider p) => p.isGpsModuleActive,
    );

    return Container(
      padding: const EdgeInsets.only(left: 10, top: 8, right: 10, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => provider.showPopupSnackBar(
              context,
              '⏰ Waktu: $time | Tanggal: $date',
              Colors.blueGrey,
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
          const SizedBox(height: 2),
          // Baris Indikator: LiDAR | Kamera | GPS (pure display)
          Row(
            children: [
              Expanded(
                child: _buildStatusIcon(
                  Icons.sensors,
                  isActive: isSensorActive,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatusIcon(
                  Icons.camera_alt_rounded,
                  isActive: isCameraActive,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatusIcon(
                  Icons.my_location_rounded,
                  isActive: isGpsModuleActive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Persentase Baterai
          GestureDetector(
            onTap: () => provider.showPopupSnackBar(
              context,
              '🔋 Baterai Rompi: $battery%',
              Colors.green,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: !isMqttConnected
                    ? Colors.grey[400]
                    : (battery <= 20
                          ? const Color.fromARGB(
                              255,
                              255,
                              59,
                              48,
                            ) // Merah jika <= 20
                          : (battery <= 50
                                ? const Color.fromARGB(
                                    255,
                                    255,
                                    204,
                                    0,
                                  ) // Kuning jika <= 50
                                : const Color.fromARGB(
                                    255,
                                    0,
                                    255,
                                    42,
                                  ))), // Hijau jika > 50
                borderRadius: BorderRadius.circular(15),
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
          AnimatedPressable(
            onTap: () => provider.refreshStatus(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 74, 0),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.black,
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Indikator murni — tanpa animasi tekan, tanpa onTap
  Widget _buildStatusIcon(
    IconData icon, {
    required bool isActive,
    String? label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color.fromARGB(255, 0, 255, 42)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.black : Colors.grey[700],
            size: 32,
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

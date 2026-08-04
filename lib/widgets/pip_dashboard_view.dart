import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class PipDashboardView extends StatelessWidget {
  const PipDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, provider, child) {
        final isMqttConnected = provider.isMqttConnected;
        final battery = provider.batteryLevel;
        final isSensorActive = provider.isSensorActive;
        final isCameraActive = provider.isCameraActive;

        // Battery level color helper matching the InfoPanel logic
        Color getBatteryColor(int level) {
          if (!isMqttConnected) return Colors.grey[400]!;
          if (level <= 20) return const Color.fromARGB(255, 255, 59, 48);
          if (level <= 50) return const Color.fromARGB(255, 255, 204, 0);
          return const Color.fromARGB(255, 0, 255, 42);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Top Section: Connection Indicator & Battery Capsule
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Connection dot + ONLINE/OFFLINE
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isMqttConnected ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isMqttConnected ? 'ONLINE' : 'OFFLINE',
                            style: TextStyle(
                              color: isMqttConnected ? Colors.green[800] : Colors.red[800],
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      // Battery Capsule
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: getBatteryColor(battery),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$battery%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Middle Section: Mini Homepage-Style SOS Button
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (provider.isSosActive) {
                            provider.cancelSos(context);
                          } else {
                            provider.handleSosTap(context);
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 0, 0),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 255, 0, 0).withAlpha(100),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 4),
                              ),
                              child: const Center(
                                child: Text(
                                  'SOS',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Bottom Section: Sensors Row & Orange Address Capsule
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sensor status row (matching status indicators in InfoPanel)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMiniStatusIcon(Icons.sensors, isActive: isSensorActive),
                          const SizedBox(width: 8),
                          _buildMiniStatusIcon(Icons.camera_alt_rounded, isActive: isCameraActive),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Deep Orange Address Capsule (matching the AddressBar)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 74, 0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          provider.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Mini version of _buildStatusIcon from InfoPanel
  Widget _buildMiniStatusIcon(IconData icon, {required bool isActive}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color.fromARGB(255, 0, 255, 42) : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.black : Colors.grey[700],
        size: 20,
      ),
    );
  }
}

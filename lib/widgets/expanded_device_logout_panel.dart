import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class ExpandedDeviceLogoutPanel extends StatelessWidget {
  const ExpandedDeviceLogoutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final statusColor = provider.isMqttConnected ? Colors.green : Colors.red;
    final statusText = provider.isSimulationActive
        ? 'Simulasi Aktif'
        : (provider.isMqttConnected
            ? 'Online (Terhubung)'
            : 'Offline (Terputus)');

    return Container(
      key: const ValueKey('device_logout_expanded'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shape_line_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Perangkat',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 28,
                ),
                onPressed: () => provider.toggleDeviceExpansion(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black26, thickness: 1.5),
          const SizedBox(height: 10),

          // Konten Utama Scrollable
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Perangkat Terhubung',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.phonelink_ring_rounded,
                  size: 50,
                  color: statusColor,
                ),
                const SizedBox(height: 24),

                // Info Perangkat
                _buildInfoTile(Icons.qr_code_rounded, 'Kode Perangkat', provider.deviceCode, isBold: true),
                _buildInfoTile(Icons.wifi_rounded, 'Status Koneksi', statusText, valueColor: statusColor, isBold: true),
                _buildInfoTile(Icons.dns_rounded, 'Server MQTT', provider.mqttHost),
                _buildInfoTile(Icons.settings_input_component_rounded, 'Port Broker', provider.mqttPort.toString()),
                
                const SizedBox(height: 28),

                // Tombol Putuskan Koneksi
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    provider.disconnectDevice();
                    provider.showPopupSnackBar(
                      context,
                      '❌ Koneksi perangkat berhasil diputuskan!',
                      Colors.red,
                    );
                  },
                  child: const Text(
                    'Putuskan Koneksi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),

                // Logo Netravest
                Center(
                  child: Image.asset(
                    'assets/images/icon_oren.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    Color valueColor = Colors.black87,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

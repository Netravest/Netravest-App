import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class ExpandedDeviceLogoutPanel extends StatelessWidget {
  const ExpandedDeviceLogoutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final statusColor = provider.isMqttConnected ? Colors.green : Colors.red;
    final statusText = provider.isMqttConnected
        ? 'Online\n(Terhubung)'
        : 'Offline\n(Terputus)';

    return Container(
      key: const ValueKey('device_logout_expanded'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Perangkat',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => provider.toggleDeviceExpansion(),
              ),
            ],
          ),

          // Scrollable Content
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 4),

                // Info Grid (2 columns, icon on top, text below)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                  children: [
                    _buildInfoBox(
                      icon: Icons.qr_code_rounded,
                      label: 'Kode Perangkat',
                      value: provider.deviceCode,
                      isBold: true,
                    ),
                    _buildInfoBox(
                      icon: Icons.wifi_rounded,
                      label: 'Status Koneksi',
                      value: statusText,
                      valueColor: statusColor,
                      isBold: true,
                    ),
                    _buildInfoBox(
                      icon: Icons.dns_rounded,
                      label: 'Database',
                      value: provider.mqttHost,
                    ),
                    _buildInfoBox(
                      icon: Icons.settings_input_component_rounded,
                      label: 'Tipe Layanan',
                      value: provider.mqttPort.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 17),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 17),

                // Disconnect Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    provider.disconnectDevice();
                    provider.showPopupSnackBar(
                      context,
                      '❌ Koneksi perangkat berhasil diputuskan!',
                      Colors.red,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link_off_rounded, size: 25),
                      SizedBox(width: 4),
                      Text(
                        'Putuskan Koneksi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.black54),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

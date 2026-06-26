import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class ExpandedSettingsPanel extends StatelessWidget {
  const ExpandedSettingsPanel({super.key});

  void _showMqttDialog(BuildContext context, EmergencyProvider provider) {
    final hostController = TextEditingController(text: provider.mqttHost);
    final portController = TextEditingController(text: provider.mqttPort.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text(
            'Konfigurasi MQTT Broker',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hostController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Host Broker',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepOrange),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Port Broker',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepOrange),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 74, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                final host = hostController.text.trim();
                final portStr = portController.text.trim();
                final port = int.tryParse(portStr);
                if (host.isNotEmpty && port != null) {
                  provider.updateMqttConfig(host, port);
                  Navigator.pop(context);
                  provider.showPopupSnackBar(
                    context,
                    '⚙️ Broker diperbarui: $host:$port',
                    Colors.green,
                  );
                } else {
                  provider.showPopupSnackBar(
                    context,
                    '⚠️ Host atau Port tidak valid!',
                    Colors.red,
                  );
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();

    return Container(
      key: const ValueKey('settings_expanded'),
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
                    Icons.settings_suggest_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pengaturan',
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
                onPressed: () => provider.toggleSettingsExpansion(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black26, thickness: 1.5),
          const SizedBox(height: 5),

          // List Pengaturan Scrollable
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Ambang Ketukan SOS
                _buildSettingTile(
                  icon: Icons.touch_app_rounded,
                  title: 'Ketukan SOS',
                  subtitle: 'Jumlah ketukan untuk memicu SOS',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: provider.sosTapThreshold,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        items: [3, 5, 8, 10].map((int val) {
                          return DropdownMenuItem<int>(
                            value: val,
                            child: Text('$val kali'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            provider.setSosTapThreshold(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // 2. Durasi Rekam Video
                _buildSettingTile(
                  icon: Icons.videocam_rounded,
                  title: 'Durasi Rekam Video',
                  subtitle: 'Durasi video rekaman rompi',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: provider.recordingDuration,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        items: [15, 30, 60, 120].map((int val) {
                          return DropdownMenuItem<int>(
                            value: val,
                            child: Text('$val detik'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            provider.setRecordingDuration(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // 3. Konfigurasi Broker MQTT
                _buildSettingTile(
                  icon: Icons.dns_rounded,
                  title: 'Broker MQTT',
                  subtitle: '${provider.mqttHost}:${provider.mqttPort}',
                  trailing: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      onPressed: () => _showMqttDialog(context, provider),
                    ),
                  ),
                ),

                // 4. Mode Simulasi
                _buildSettingTile(
                  icon: Icons.bolt_rounded,
                  title: 'Simulasi Telemetri',
                  subtitle: 'Simulasikan data rompi saat offline',
                  trailing: Switch(
                    key: const Key('switch_simulation'),
                    value: provider.isSimulationActive,
                    activeThumbColor: const Color.fromARGB(255, 255, 74, 0),
                    onChanged: (bool value) {
                      provider.toggleSimulation(value);
                      provider.showPopupSnackBar(
                        context,
                        value
                            ? '⚡ Mode Simulasi Telemetri Aktif!'
                            : '🔌 Menghubungkan ke Broker MQTT...',
                        value ? Colors.orange : Colors.blue,
                      );
                    },
                  ),
                ),

                // 5. Mode Kidal
                _buildSettingTile(
                  icon: Icons.front_hand_rounded,
                  title: 'Mode Kidal',
                  subtitle: 'Tukar posisi layout tombol untuk kidal',
                  trailing: Switch(
                    key: const Key('switch_left_handed'),
                    value: provider.isLeftHanded,
                    activeThumbColor: const Color.fromARGB(255, 255, 74, 0),
                    onChanged: (bool value) {
                      provider.toggleLeftHanded(value);
                    },
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 10),

                // 5. Reset Defaults
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      provider.resetSettings();
                      provider.showPopupSnackBar(
                        context,
                        '🔄 Pengaturan berhasil di-reset!',
                        Colors.green,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restore_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Kembalikan Default',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black12,
                child: Icon(icon, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

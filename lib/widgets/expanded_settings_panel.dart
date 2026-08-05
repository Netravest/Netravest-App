import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/emergency_provider.dart';

class ExpandedSettingsPanel extends StatelessWidget {
  const ExpandedSettingsPanel({super.key});



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

                // 3. Database Telemetri
                _buildSettingTile(
                  icon: Icons.cloud_done_rounded,
                  title: 'Database Telemetri',
                  subtitle: 'Google Cloud Firestore',
                  trailing: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
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
                            : '🔌 Sinkronisasi Cloud Firestore Aktif...',
                        value ? Colors.orange : Colors.blue,
                      );
                    },
                  ),
                ),

                // 5. Sumber Lokasi HP
                _buildSettingTile(
                  icon: Icons.gps_fixed_rounded,
                  title: 'Gunakan GPS HP',
                  subtitle: 'Gunakan GPS HP tunanetra (bukan GSM Rompi)',
                  trailing: Switch(
                    key: const Key('switch_phone_gps'),
                    value: provider.usePhoneGps,
                    activeThumbColor: const Color.fromARGB(255, 255, 74, 0),
                    onChanged: (bool value) {
                      provider.toggleUsePhoneGps(value, context);
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

                // 6. Keluar Akun (Sign Out)
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      // Tutup panel pengaturan
                      provider.toggleSettingsExpansion();
                      
                      // Putuskan koneksi perangkat
                      provider.disconnectDevice();
                      
                      // Sign out Firebase & Google Sign In
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn.instance.signOut();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Keluar Akun',
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

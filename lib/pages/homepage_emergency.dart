import 'package:flutter/material.dart';
import 'package:netravest/widgets/settings_button.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/sos_button.dart';
import '../widgets/address_bar.dart';
import '../widgets/info_panel.dart';

class BerandaEmergency extends StatelessWidget {
  const BerandaEmergency({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tombol SOS Besar (Merah)
              const SOSButton(),
              const SizedBox(height: 16),

              // 2. Baris Alamat & Bagikan Lokasi (Putih)
              const AddressBar(),
              const SizedBox(height: 16),

              // 3. Grid Menu Utama di bagian bawah
              Expanded(
                child: Row(
                  children: [
                    // Kolom Kiri
                    Expanded(
                      child: Column(
                        children: [
                          const Expanded(flex: 4, child: InfoPanel()),
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 2,
                            child: SettingsButton(
                              color: Colors.white,
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.settings_rounded,
                              label: 'Pengaturan',
                              onTap: () => provider.openSettings(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Kolom Kanan
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: SettingsButton(
                              color: const Color.fromARGB(255, 255, 74, 0),
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.space_dashboard_rounded,
                              label: 'Mengambang',
                              onTap: () => provider.toggleFloatingWidget(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SettingsButton(
                              color: Colors.white,
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.shape_line_rounded,
                              label: 'Perangkat',
                              onTap: () => provider.manageDevice(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SettingsButton(
                              color: const Color.fromARGB(255, 255, 74, 0),
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.phone_rounded,
                              label: 'Telepon',
                              onTap: () => provider.makeCall(context),
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
        ),
      ),
    );
  }
}

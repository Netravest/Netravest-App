import 'package:flutter/material.dart';
import 'package:netravest/widgets/settings_button.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/sos_button.dart';
import '../widgets/address_bar.dart';
import '../widgets/info_panel.dart';
import '../widgets/expanded_call_panel.dart';
import '../widgets/expanded_settings_panel.dart';
import '../widgets/expanded_device_logout_panel.dart';

class BerandaEmergency extends StatelessWidget {
  const BerandaEmergency({super.key});

  void _showAddContactDialog(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text(
            'Tambah Kontak Darurat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Kontak',
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
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
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty && phone.isNotEmpty) {
                  if (!provider.canAddContact) {
                    Navigator.pop(context);
                    provider.showPopupSnackBar(
                      context,
                      '⚠️ Maksimal hanya 3 kontak tambahan terdekat!',
                      Colors.orange,
                    );
                    return;
                  }
                  provider.addContact(name, phone);
                  Navigator.pop(context);
                  provider.showPopupSnackBar(
                    context,
                    '✅ Kontak "$name" berhasil ditambahkan!',
                    Colors.green,
                  );
                } else {
                  provider.showPopupSnackBar(
                    context,
                    '⚠️ Nama dan Nomor tidak boleh kosong!',
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
    final provider = context.read<EmergencyProvider>();
    final isCallExpanded = context.select(
      (EmergencyProvider p) => p.isCallExpanded,
    );
    final isSettingsExpanded = context.select(
      (EmergencyProvider p) => p.isSettingsExpanded,
    );
    final isDeviceExpanded = context.select(
      (EmergencyProvider p) => p.isDeviceExpanded,
    );
    final isLeftHanded = context.select(
      (EmergencyProvider p) => p.isLeftHanded,
    );

    final leftColumn = Expanded(
      child: isSettingsExpanded
          ? const ExpandedSettingsPanel()
          : (isDeviceExpanded
              ? const ExpandedDeviceLogoutPanel()
              : Column(
                  children: [
                    const Expanded(flex: 4, child: InfoPanel()),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 2,
                      child: SettingsButton(
                        color: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        icon: Icons.shape_line_rounded,
                        label: 'Perangkat',
                        onTap: () => provider.manageDevice(context),
                      ),
                    ),
                  ],
                )),
    );

    final hideRightColumn = isSettingsExpanded || isDeviceExpanded;

    final rightColumn = Expanded(
      child: Column(
        children: [
          if (!isCallExpanded) ...[
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
                icon: Icons.settings_rounded,
                label: 'Pengaturan',
                onTap: () => provider.toggleSettingsExpansion(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Tombol Telepon (Membesar jika isCallExpanded = true)
          Expanded(
            child: isCallExpanded
                ? ExpandedCallPanel(
                    onAddContact: () => _showAddContactDialog(context),
                  )
                : SettingsButton(
                    color: const Color.fromARGB(
                      255,
                      255,
                      74,
                      0,
                    ),
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    icon: Icons.phone_rounded,
                    label: 'Telepon',
                    onTap: () => provider.toggleCallExpansion(),
                  ),
          ),
        ],
      ),
    );

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
                    if (isLeftHanded) ...[
                      if (!hideRightColumn) rightColumn,
                      if (!hideRightColumn && !isCallExpanded) const SizedBox(width: 16),
                      if (!isCallExpanded) leftColumn,
                    ] else ...[
                      if (!isCallExpanded) leftColumn,
                      if (!hideRightColumn && !isCallExpanded) const SizedBox(width: 16),
                      if (!hideRightColumn) rightColumn,
                    ],
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

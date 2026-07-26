import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/info_panel.dart';
import '../widgets/expanded_settings_panel.dart';
import '../widgets/expanded_call_panel.dart';
import '../widgets/expanded_device_logout_panel.dart';
import '../widgets/settings_button.dart';
import '../widgets/animated_pressable.dart';

class BerandaPendamping extends StatelessWidget {
  const BerandaPendamping({super.key});

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
            borderRadius: BorderRadius.circular(20),
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
    final provider = context.watch<EmergencyProvider>();
    final isCallExpanded = provider.isCallExpanded;
    final isSettingsExpanded = provider.isSettingsExpanded;
    final isDeviceExpanded = provider.isDeviceExpanded;

    Widget middleContent;
    if (isSettingsExpanded) {
      middleContent = const ExpandedSettingsPanel();
    } else if (isCallExpanded) {
      middleContent = ExpandedCallPanel(
        onAddContact: () => _showAddContactDialog(context),
      );
    } else if (isDeviceExpanded) {
      middleContent = const ExpandedDeviceLogoutPanel();
    } else {
      middleContent = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: const InfoPanel(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const _CompanionDevicePanel(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Card: Address and Map Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => provider.copyAddress(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 74, 0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          provider.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        'assets/images/map_placeholder.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Tampilan fallback interaktif jika aset gambar belum di-restart
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map_outlined, color: Colors.black54, size: 50),
                                  SizedBox(height: 8),
                                  Text(
                                    'Lakukan Hot Restart (R) atau jalankan ulang\naplikasi untuk memuat peta baru.',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Middle Content (Info & Device or Expanded Panel)
              Expanded(
                flex: 3,
                child: middleContent,
              ),
              const SizedBox(height: 16),

              // 3. Bottom Row: Action Buttons
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: SettingsButton(
                        color: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        icon: Icons.menu_rounded, // Ikon garis tiga (☰)
                        label: 'Pengaturan',
                        onTap: () => provider.toggleSettingsExpansion(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SettingsButton(
                        color: const Color.fromARGB(255, 255, 74, 0),
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        icon: Icons.phone_rounded, // Ikon telepon (📞)
                        label: 'Telepon',
                        onTap: () => provider.toggleCallExpansion(),
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

class _CompanionDevicePanel extends StatelessWidget {
  const _CompanionDevicePanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final isSosActive = provider.isSosActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 74, 0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Putuskan dengan Animasi
          AnimatedPressable(
            onTap: () {
              provider.disconnectDevice();
              provider.showPopupSnackBar(
                context,
                '❌ Koneksi perangkat berhasil diputuskan!',
                Colors.red,
              );
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: const Color.fromARGB(255, 255, 0, 0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  'Putuskan',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
          ),

          // Wadah Abu-abu (Kotak Sempurna) di belakang SOS Ring Ganda
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[400], // Warna latar belakang abu-abu persis gambar
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 6), // Ring luar
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSosActive ? Colors.red : Colors.grey[500],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            color: isSosActive ? Colors.white : Colors.black26,
                            fontSize: 45,
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

          // Kapsul Kode Perangkat
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kode:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  provider.deviceCode,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Kapsul Database Telemetri
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Database:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Firestore',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:netravest/widgets/settings_button.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/sos_button.dart';
import '../widgets/address_bar.dart';
import '../widgets/info_panel.dart';

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

  Widget _buildExpandedCallPanel(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    final contacts = context.select((EmergencyProvider p) => p.contacts);

    return Container(
      key: const ValueKey('phone_expanded'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 74, 0),
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
                    Icons.phone_in_talk_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Telepon',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Tombol Tambah Kontak
                  IconButton(
                    icon: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () => _showAddContactDialog(context),
                  ),
                  // Tombol Tutup (Collapse)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () => provider.toggleCallExpansion(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black26, thickness: 1.5),
          const SizedBox(height: 8),

          // Daftar Kontak
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person_rounded, color: Colors.white),
                      ),
                      title: Text(
                        contact['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        contact['phone'] ?? '',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.call, color: Colors.white, size: 18),
                      ),
                      onTap: () => provider.makeCall(
                        context,
                        name: contact['name'],
                        phone: contact['phone'],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    final isExpanded = context.select(
      (EmergencyProvider p) => p.isCallExpanded,
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
                    // Kolom Kiri - Hanya ditampilkan jika tombol telepon TIDAK membesar
                    if (!isExpanded) ...[
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
                    ],
                    // Kolom Kanan
                    Expanded(
                      child: Column(
                        children: [
                          if (!isExpanded) ...[
                            Expanded(
                              child: SettingsButton(
                                color: const Color.fromARGB(255, 255, 74, 0),
                                textColor: Colors.black,
                                iconColor: Colors.black,
                                icon: Icons.space_dashboard_rounded,
                                label: 'Mengambang',
                                onTap: () =>
                                    provider.toggleFloatingWidget(context),
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
                          ],
                          // Tombol Telepon (Membesar jika isExpanded = true)
                          Expanded(
                            child: isExpanded
                                ? _buildExpandedCallPanel(context)
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

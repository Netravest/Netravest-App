import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class ExpandedCallPanel extends StatelessWidget {
  final VoidCallback onAddContact;

  const ExpandedCallPanel({super.key, required this.onAddContact});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    final contacts = context.select((EmergencyProvider p) => p.contacts);
    final canAdd = contacts.length < 5;

    return Container(
      key: const ValueKey('phone_expanded'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 74, 0),
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (close button only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.phone_in_talk_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Telepon',
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
                onPressed: () => provider.toggleCallExpansion(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Daftar Kontak sebagai List Vertikal (1 Kolom)
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final name = contact['name'] ?? '';
                final phone = contact['phone'] ?? '';
                return _buildContactBox(
                  context: context,
                  provider: provider,
                  name: name,
                  phone: phone,
                  index: index,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Tombol Tambah Kontak — full-width, style seperti tombol Panduan
          SizedBox(
            height: 100,
            child: Material(
              color: canAdd ? const Color(0xFF1A1A2E) : const Color(0xFF3A3A4E),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: canAdd
                    ? onAddContact
                    : () => provider.showPopupSnackBar(
                        context,
                        '⚠️ Maksimal hanya 5 kontak!',
                        Colors.orange,
                      ),
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white24,
                highlightColor: Colors.white12,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        color: canAdd ? Colors.white : Colors.white38,
                        size: 40,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tambah Kontak',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: canAdd ? Colors.white : Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan Kartu Kontak Sesuai Desain Gambar
  Widget _buildContactBox({
    required BuildContext context,
    required EmergencyProvider provider,
    required String name,
    required String phone,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          // Sisi Kiri: Foto, Nama, dan Nomor Telepon
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.person_rounded, 
                    color: Colors.white, 
                    size: 30, 
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Sisi Kanan: Tombol Telepon Oranye & Tombol Hapus Merah
          SizedBox(
            width: 130,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Panggil Telepon (Oranye)
                InkWell(
                  onTap: () =>
                      provider.makeCall(context, name: name, phone: phone),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4A00),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: Colors.black,
                      size: 42,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tombol Hapus (Merah)
                InkWell(
                  onTap: () {
                    provider.deleteContact(index);
                    provider.showPopupSnackBar(
                      context,
                      '🗑️ Kontak "$name" berhasil dihapus!',
                      Colors.red[800]!,
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete),
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

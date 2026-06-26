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
                    icon: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: contacts.length < 5 ? Colors.black : Colors.black38,
                      size: 28,
                    ),
                    onPressed: contacts.length < 5
                        ? onAddContact
                        : () => provider.showPopupSnackBar(
                              context,
                              '⚠️ Maksimal hanya 3 kontak tambahan terdekat!',
                              Colors.orange,
                            ),
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.white.withAlpha(38),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, color: Colors.black87),
                            onPressed: () {
                              final name = contact['name'] ?? '';
                              provider.deleteContact(index);
                              provider.showPopupSnackBar(
                                context,
                                '🗑️ Kontak "$name" berhasil dihapus!',
                                Colors.red[800]!,
                              );
                            },
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(Icons.call, color: Colors.white, size: 18),
                          ),
                        ],
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
}

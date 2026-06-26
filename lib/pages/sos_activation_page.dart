import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class SosActivationPage extends StatelessWidget {
  const SosActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
    final nearestContact = provider.contacts.isNotEmpty ? provider.contacts.last : null;
    final nearestContactName = nearestContact != null ? nearestContact['name'] : 'Rekan Terdekat';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon emergency kedip merah
              const Icon(
                Icons.warning_amber_rounded,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 130,
              ),
              const SizedBox(height: 20),
              const Text(
                'SOS AKTIF',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Status telemetri darurat
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red.withAlpha(50), width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildStatusRow(
                      Icons.videocam_rounded,
                      'Kamera Rompi',
                      'Merekam Sekitar...',
                      Colors.red,
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildStatusRow(
                      Icons.phone_in_talk_rounded,
                      'Panggilan Suara',
                      'Menghubungi $nearestContactName...',
                      Colors.green,
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _buildStatusRow(
                      Icons.my_location_rounded,
                      'Lokasi GPS',
                      'Mengirim koordinat terkini...',
                      Colors.blue,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Tombol Batalkan SOS
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () => provider.cancelSos(context),
                child: const Text(
                  'BATALKAN SOS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

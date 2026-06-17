import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const BerandaEmergency(),
    );
  }
}

class BerandaEmergency extends StatelessWidget {
  const BerandaEmergency({super.key});

  void _showPopupSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tombol SOS Besar (Merah)
              GestureDetector(
                onTap: () {
                  _showPopupSnackBar(
                    context,
                    '⚠️ SOS DIKIRIM! Menghubungi pusat bantuan...',
                    Colors.red,
                  );
                },
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 17, 0),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 10),
                      ),
                      child: const Text(
                        'SOS',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Baris Alamat & Bagikan Lokasi (Putih)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    // Kotak Alamat (Oranye)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showPopupSnackBar(
                            context,
                            '📍 Alamat disalin ke clipboard!',
                            Colors.deepOrange,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 74, 0),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'Jln. Lorem Ipsum No 013,\nKec. Dolor SitAmet',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Tombol Bagikan Lokasi (Hitam)
                    GestureDetector(
                      onTap: () {
                        _showPopupSnackBar(
                          context,
                          '📤 Membagikan lokasi GPS Anda...',
                          Colors.black,
                        );
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            Text(
                              'Bagikan\nLokasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Grid Menu Utama di bagian bawah
              Expanded(
                child: Row(
                  children: [
                    // Kolom Kiri
                    Expanded(
                      child: Column(
                        children: [
                          // Widget Jam, Persentase, dan Refresh
                          Expanded(flex: 4, child: _buildInfoPanel(context)),
                          const SizedBox(height: 16),
                          // Tombol Pengaturan
                          Expanded(
                            flex: 2,
                            child: _buildMenuButton(
                              color: Colors.white,
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.settings_rounded,
                              label: 'Pengaturan',
                              onTap: () {
                                _showPopupSnackBar(
                                  context,
                                  '⚙️ Membuka Pengaturan aplikasi...',
                                  Colors.grey,
                                );
                              },
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
                          // Tombol Mengambang
                          Expanded(
                            child: _buildMenuButton(
                              color: Color.fromARGB(255, 255, 74, 0),
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.space_dashboard_rounded,
                              label: 'Mengambang',
                              onTap: () {
                                _showPopupSnackBar(
                                  context,
                                  '📱 Mengaktifkan Widget Mengambang...',
                                  Colors.deepOrange,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol Perangkat
                          Expanded(
                            child: _buildMenuButton(
                              color: Colors.white,
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.shape_line_rounded,
                              label: 'Perangkat',
                              onTap: () {
                                _showPopupSnackBar(
                                  context,
                                  '🛡️ Membuka menu kelola Perangkat...',
                                  Colors.grey,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol Telepon
                          Expanded(
                            child: _buildMenuButton(
                              color: Color.fromARGB(255, 255, 74, 0),
                              textColor: Colors.black,
                              iconColor: Colors.black,
                              icon: Icons.phone_rounded,
                              label: 'Telepon',
                              onTap: () {
                                _showPopupSnackBar(
                                  context,
                                  '📞 Melakukan panggilan darurat...',
                                  Colors.deepOrange,
                                );
                              },
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

  // Fungsi bantuan untuk membuat panel info sebelah kiri (Jam & Indikator)
  Widget _buildInfoPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              _showPopupSnackBar(
                context,
                '⏰ Waktu saat ini: 19:20 | Tanggal: 6/17/26',
                Colors.blueGrey,
              );
            },
            child: const Column(
              children: [
                Text(
                  '19:20',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  '6/17/26',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSmallGreenIcon(
                Icons.sensors,
                onTap: () {
                  _showPopupSnackBar(
                    context,
                    '📡 Sensor aktif dan memantau status...',
                    Colors.green,
                  );
                },
              ),
              _buildSmallGreenIcon(
                Icons.camera_alt_rounded,
                onTap: () {
                  _showPopupSnackBar(
                    context,
                    '📷 Akses kamera darurat aktif...',
                    Colors.green,
                  );
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _showPopupSnackBar(
                context,
                '🔋 Baterai perangkat terisi penuh (100%)',
                Colors.green,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 255, 42),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                '100%',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showPopupSnackBar(
                context,
                '🔄 Menyegarkan status koneksi dan data...',
                Colors.deepOrange,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 74, 0),
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.black, size: 80),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi bantuan untuk ikon hijau kecil
  Widget _buildSmallGreenIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 255, 42),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.black, size: 50),
      ),
    );
  }

  // Fungsi bantuan untuk membuat tombol menu utama
  Widget _buildMenuButton({
    required Color color,
    required Color textColor,
    required Color iconColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 100),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

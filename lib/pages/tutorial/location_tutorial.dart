import 'package:flutter/material.dart';

List<Map<String, dynamic>> getLocationTutorialData(BuildContext context) {
  return [
    {
      'description': 'Bagikan lokasi GPS presisi Anda ke kontak terdekat secara otomatis.',
      'bullets': [
        'Aplikasi mendeteksi lokasi real-time Anda secara terus menerus.',
        'Tekan bagian kanan tombol alamat (ikon panah) untuk membagikan tautan peta lokasi Anda.',
        'Pendamping Anda dapat memantau pergerakan Anda secara langsung di peta mereka.'
      ],
    }
  ];
}

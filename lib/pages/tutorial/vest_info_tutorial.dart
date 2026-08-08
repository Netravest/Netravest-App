import 'package:flutter/material.dart';

List<Map<String, dynamic>> getVestInfoTutorialData(BuildContext context) {
  return [
    {
      'description': 'Pantau telemetri real-time, status baterai, dan sensor LiDAR rompi.',
      'bullets': [
        'Gunakan halaman Informasi Rompi untuk melihat persentase sisa baterai rompi.',
        'Pantau apakah kamera pengenal objek dan sensor LiDAR pemindai rintangan berfungsi normal.',
        'Lihat riwayat konektivitas data dan sisa memori penyimpanan internal modul rompi.'
      ],
    }
  ];
}

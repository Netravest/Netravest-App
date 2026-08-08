import 'package:flutter/material.dart';

List<Map<String, dynamic>> getAccountTutorialData(BuildContext context) {
  return [
    {
      'description': 'Kelola akun Google/email Anda untuk sinkronisasi data antar perangkat.',
      'bullets': [
        'Masuk menggunakan akun Google atau email aktif Anda.',
        'Data konfigurasi dan kontak darurat Anda akan disinkronkan secara otomatis ke Cloud Firestore.',
        'Anda dapat memulihkan konfigurasi Anda kapan saja saat berpindah perangkat.'
      ],
    }
  ];
}

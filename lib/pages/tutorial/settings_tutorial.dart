import 'package:flutter/material.dart';

List<Map<String, dynamic>> getSettingsTutorialData(BuildContext context) {
  return [
    {
      'description': 'Konfigurasi preference aplikasi agar sesuai dengan kebutuhan kenyamanan Anda.',
      'bullets': [
        'Atur ambang batas ketukan tombol SOS untuk menghindari ketidaksengajaan.',
        'Pilih jenis notifikasi suara atau getaran yang ingin diaktifkan.',
        'Sesuaikan durasi rekaman video darurat saat alarm aktif.'
      ],
    }
  ];
}

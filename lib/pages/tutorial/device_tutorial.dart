import 'package:flutter/material.dart';

List<Map<String, dynamic>> getDeviceTutorialData(BuildContext context) {
  return [
    {
      'description': 'Hubungkan ponsel ke modul rompi pintar Anda menggunakan koneksi nirkabel.',
      'bullets': [
        'Pastikan Bluetooth ponsel Anda aktif.',
        'Pilih opsi "Sambungkan Perangkat" dan cari nama perangkat rompi Netravest Anda.',
        'Setelah terhubung, indikator status koneksi di beranda ponsel akan berubah hijau.'
      ],
    }
  ];
}

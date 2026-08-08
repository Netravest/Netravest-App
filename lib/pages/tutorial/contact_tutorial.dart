import 'package:flutter/material.dart';

List<Map<String, dynamic>> getContactTutorialData(BuildContext context) {
  return [
    {
      'description': 'Kelola kontak darurat penting untuk menerima pemberitahuan SOS.',
      'bullets': [
        'Tambahkan kontak keluarga, kerabat dekat, atau nomor darurat resmi.',
        'Pastikan nomor yang didaftarkan aktif dan dapat menerima SMS/panggilan.',
        'Anda dapat menguji pengiriman pesan darurat di halaman pengaturan kontak.'
      ],
    }
  ];
}

import 'package:flutter/material.dart';

List<Map<String, dynamic>> getSosTutorialData(BuildContext context) {
  return [
    {
      'description': 'Tombol SOS digunakan untuk memicu alarm darurat saat keadaan kritis.',
      'bullets': [
        'Tekan tombol SOS berwarna merah di halaman utama untuk mengaktifkan mode darurat.',
        'Sistem akan mengirimkan pesan bantuan dan notifikasi ke pendamping secara otomatis.',
        'Anda dapat menghentikan alarm dengan memasukkan PIN keamanan yang telah dikonfigurasi.'
      ],
    }
  ];
}

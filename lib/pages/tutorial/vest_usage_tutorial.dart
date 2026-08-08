import 'package:flutter/material.dart';

List<Map<String, dynamic>> getVestUsageTutorialData(BuildContext context) {
  return [
    {
      'description': 'Langkah awal untuk mengenakan rompi pintar Netravest dengan benar.',
      'bullets': [
        'Kenakan rompi Netravest dan kencangkan ritsleting depan dengan rapat.',
        'Sesuaikan tali pengikat samping agar rompi pas di badan dan tidak bergeser.',
        'Pastikan posisi kamera dan sensor LiDAR di dada menghadap lurus ke depan tanpa terhalang pakaian.'
      ],
    },
    {
      'description': 'Cara menyalakan dan mematikan modul utama rompi pintar Anda.',
      'bullets': [
        'Temukan tombol daya (power) berbentuk bulat di modul utama sebelah kanan dada.',
        'Tekan dan tahan tombol daya selama 3 detik hingga rompi bergetar 2 kali menandakan aktif.',
        'Untuk mematikannya, tekan dan tahan kembali tombol daya selama 3 detik hingga ada getaran panjang.'
      ],
    },
    {
      'description': 'Cara membaca getaran sensor (haptic feedback) sebagai navigasi rintangan.',
      'bullets': [
        'Getaran di pundak/pinggang kiri: Terdeteksi rintangan di sisi kiri Anda.',
        'Getaran di pundak/pinggang kanan: Terdeteksi rintangan di sisi kanan Anda.',
        'Getaran cepat & kuat di kedua sisi: Ada rintangan dekat tepat di depan Anda. Berhentilah sejenak!'
      ],
    },
  ];
}

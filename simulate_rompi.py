import time
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# 1. Inisialisasi Firebase Admin SDK menggunakan key proyek Anda
# Pastikan Anda sudah mengunduh 'serviceAccountKey.json' dari Firebase Console -> Project Settings -> Service Accounts
# Dan menyimpannya di folder proyek ini.
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print("❌ ERROR: Gagal memuat serviceAccountKey.json.")
    print("Silakan unduh file serviceAccountKey.json dari Firebase Console -> Project Settings -> Service Accounts")
    print("dan letakkan di folder proyek netravest Anda sebelum menjalankan skrip ini.")
    exit(1)

# Pilih dokumen target (NV-1001 atau NV-1002)
DEVICE_CODE = "NV-1001"
doc_ref = db.collection("telemetri_rompi").document(DEVICE_CODE)

print(f"⚡ Memulai Simulasi Pengiriman Data Rompi untuk Perangkat: {DEVICE_CODE}")
print("Tekan Ctrl+C untuk menghentikan simulasi.")

# Simulasi baterai berkurang
battery = 100

try:
    while True:
        # Simulasi penurunan baterai agar Anda bisa melihat warna indikator di HP berubah secara dinamis
        battery -= 5
        if battery < 10:
            battery = 100 # Reset kembali ke 100 jika habis
            
        # Simulasi status sensor
        lidar_aktif = True
        kamera_aktif = True
        
        # Koordinat GPS DKI Jakarta
        latitude = -6.2088
        longitude = 106.8456
        titik_koordinat = firestore.GeoPoint(latitude, longitude)

        # Kirim data ke Firestore dengan field yang Anda buat di konsol
        doc_ref.set({
            "AlamatLokasi": "Jakarta, Indonesia",
            "LongLatLokasi": titik_koordinat,
            "PersentaseBaterai": battery,
            "StatusKamera": kamera_aktif,
            "StatusLidar": lidar_aktif,
            # SERVER_TIMESTAMP adalah fungsi bawaan Firebase untuk menulis waktu real-time server yang presisi secara otomatis
            "Timestap": firestore.SERVER_TIMESTAMP 
        }, merge=True)

        print(f"📤 Data terkirim ke Firestore -> Baterai: {battery}% | Waktu: Real-time Server Timestamp")
        
        # Kirim data setiap 3 detik agar Anda bisa melihat perubahan real-time
        time.sleep(3)

except KeyboardInterrupt:
    print("\n👋 Simulasi dihentikan.")

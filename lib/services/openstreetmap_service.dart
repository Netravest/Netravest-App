import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenStreetMapService {
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'NetravestApp/1.0 (companion-vest-research)'
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Coba memformat alamat yang lebih pendek dan bersih agar pas di UI
        final address = data['address'];
        if (address != null) {
          final road = address['road'] ?? address['pedestrian'] ?? address['path'] ?? address['suburb'] ?? '';
          final village = address['village'] ?? address['town'] ?? address['city_district'] ?? '';
          final city = address['city'] ?? address['municipality'] ?? address['state'] ?? '';
          
          final List<String> parts = [];
          if (road.isNotEmpty) parts.add(road.toString());
          if (village.isNotEmpty) parts.add(village.toString());
          if (city.isNotEmpty) parts.add(city.toString());
          
          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }

        final displayName = data['display_name'];
        if (displayName != null) {
          return displayName.toString();
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
    return null;
  }
}

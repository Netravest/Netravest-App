import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'NetravestApp/1.0 (companion-vest-research)'
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'];
        if (displayName != null) {
          return displayName.toString();
        }
      }
    } catch (e) {
      print('Geocoding Error: $e');
    }
    return null;
  }
}

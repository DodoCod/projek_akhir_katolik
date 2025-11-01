import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 

class LocationService {
  
  /// Meminta izin lokasi dan mengembalikan posisi GPS (Latitude/Longitude) saat ini.
  static Future<Position> getCurrentPosition() async {
    // 1. Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Buka pengaturan aplikasi.');
    }

    // 2. Dapatkan koordinat (Lat/Lng)
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// Menghitung jarak antara dua titik koordinat.
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Mengkonversi koordinat (Lat/Lng) menjadi nama lokasi (Alamat Jalan/Kota) menggunakan Reverse Geocoding.
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        List<String> addressParts = [];

        // 1. Prioritaskan Nama Jalan (thoroughfare) atau sub-area terdekat (subLocality)
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressParts.add(place.thoroughfare!);
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        // 2. Tambahkan Kota/Kecamatan
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        } else if (place.locality != null && place.locality!.isNotEmpty) {
           addressParts.add(place.locality!);
        }

        // 3. Gabungkan menjadi satu string, membersihkan koma berlebihan
        String result = addressParts.join(', ');

        if (result.isEmpty) {
             return place.administrativeArea ?? "Lokasi tidak terdeteksi (Tersedia data Lat/Long)";
        }
        
        return result;
      }
      return "Lokasi tidak dikenali.";
    } catch (e) {
      // Mengembalikan Lat/Lng jika geocoding gagal (misal: masalah jaringan)
      return "Gagal mendapatkan nama lokasi (Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)})";
    }
  }
}
import 'package:flutter/material.dart';

/// Merepresentasikan Hari Liturgi tertentu, berisi detail perayaan dan bacaan.
class LiturgicalDay {
  final String date;
  final String season;
  final String title;
  
  /// Warna liturgi dalam format string (e.g., 'green', 'violet').
  final String color;

  LiturgicalDay({
    required this.date,
    required this.season,
    required this.title,
    required this.color,
  });

  /// Membuat instance LiturgicalDay dari Map (respons API).
  /// Asumsi: Data perayaan (celebrations) berada di dalam json['celebrations'][0].
  factory LiturgicalDay.fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('celebrations') || json['celebrations'].isEmpty) {
        throw Exception('Celebrations data is missing or empty');
      }
      
      // Ambil perayaan utama (asumsi selalu di indeks 0)
      var celebration = json['celebrations'][0];
  
      return LiturgicalDay(
        date: json['date'] ?? 'Unknown',
        season: json['season'] ?? 'Unknown',
        title: celebration['title'] ?? 'Unknown',
        // Mengambil warna dari kunci 'colour' (ejaan British)
        color: celebration['colour'] ?? 'green', 
      );
    } catch (e) {
      // Logika rethrow penting untuk menangani error parsing di lapisan atas
      throw Exception('Error parsing LiturgicalDay data: $e');
    }
  }
  
  /// Getter yang mengembalikan objek Color dari string warna liturgi.
  Color get liturgicalColor {
    switch (color.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'white':
        return Colors.white;
      case 'violet':
      case 'purple':
        return Colors.purple;
      case 'rose':
      case 'pink':
        return Colors.pink.shade200;
      case 'black':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }
}
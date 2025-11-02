import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir_katolik/models/liturgical_day.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';
import 'package:intl/intl.dart';

class LiturgyService {
  
  /// Base URL untuk API Kalender Liturgi.
  final String _baseUrl = ApiConstants.liturgyBaseUrl;

  /// Mengambil data liturgi untuk hari ini.
  Future<LiturgicalDay> getTodaysLiturgy() async {
    return getLiturgyForDate(DateTime.now());
  }

  Future<LiturgicalDay> getLiturgyForDate(DateTime date) async {
    // Format: YYYY/MM/DD
    final dateStr = DateFormat('yyyy/MM/dd').format(date);
    final url = "$_baseUrl/$dateStr";
    
    try {
      final response = await http.get(  
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout. Cek internet Anda.');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Validasi struktur data
        if (!data.containsKey('celebrations') || data['celebrations'].isEmpty) {
          throw Exception('Data celebrations tidak ditemukan atau kosong');
        }
        
        // Parsing LiturgicalDay (yang kini tidak mengharapkan kunci 'readings' di model)
        final liturgy = LiturgicalDay.fromJson(data);
        return liturgy;
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on FormatException {
      throw Exception('Format data tidak valid (JSON error)');
    } catch (e) {
      // Mengembalikan dummy data jika terjadi kesalahan jaringan atau parsing
      return _getDummyData(date);
    }
  }
  
  /// Data dummy statis untuk pengujian (digunakan saat koneksi API gagal).
  LiturgicalDay _getDummyData(DateTime date) {
    return LiturgicalDay(
      date: DateFormat('yyyy-MM-dd').format(date),
      season: 'Ordinary Time',
      title: 'Liturgy for ${DateFormat('EEEE, MMMM dd, yyyy').format(date)} (Dummy)',
      color: 'green',
    );
  }
}
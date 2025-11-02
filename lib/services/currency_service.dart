import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir_katolik/utils/constants.dart'; 

/// Layanan untuk mengambil kurs mata uang real-time dari API eksternal.
class CurrencyService {
  
  /// Mengambil kurs konversi mata uang dari USD ke mata uang target.
  Future<Map<String, dynamic>> getConversionRates() async {
    
    // Daftar mata uang target yang ingin dikonversi dari USD
    const String targetCurrencies = 'IDR,EUR,JPY,MYR';

    // Membangun URL dengan access key dari ApiConstants
    final uri = Uri.parse(
      '${ApiConstants.currencyBaseUrl}?access_key=${ApiConstants.currencyApiKey}&currencies=$targetCurrencies'
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Mengembalikan seluruh map 'quotes' yang berisi kurs
          return data['quotes'];
        } else {
          // Menangani error spesifik dari API
          String errorMsg = data['error']?['info'] ?? 'Unknown API error';
          throw Exception('Gagal memuat kurs: $errorMsg');
        }
      } else {
        // Menangani error koneksi HTTP (non-200 status code)
        throw Exception('Gagal terhubung ke server mata uang: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani error jaringan umum (SocketException, Timeout)
      throw Exception('Error fetching rates: ${e.toString()}');
    }
  }
}
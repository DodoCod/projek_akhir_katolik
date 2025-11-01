import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir_katolik/utils/constants.dart'; 

class BibleService {
  final String _baseUrl = ApiConstants.bibleBaseUrl;

  /// Mengambil daftar semua kitab Alkitab yang tersedia dari API.
  /// Jika gagal, mengembalikan daftar dummy.
  Future<List<BibleBook>> getBookList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/passage/list'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = jsonDecode(response.body);

        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          final List<dynamic> data = responseMap['data'];
          return data.map((json) => BibleBook.fromJson(json)).toList();
        } else {
          throw Exception('Struktur JSON tidak terduga: key "data" tidak ditemukan atau bukan List');
        }
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      return _getDummyBooks();
    }
  }

  /// Mengembalikan daftar kitab dummy (fallback) saat koneksi API gagal.
  List<BibleBook> _getDummyBooks() {
    return [
      BibleBook(abbr: 'Gen', chapter: 50, name: 'Kejadian (Dummy)', testament: 'old'),
      BibleBook(abbr: 'Matt', chapter: 28, name: 'Matius (Dummy)', testament: 'new'),
    ];
  }

  /// Mengambil isi pasal Alkitab spesifik dari API.
  Future<BiblePassage> getPassage(String book, int chapter) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/passage/$book/$chapter'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BiblePassage.fromJson(data);
      } else {
        throw Exception('Failed to load passage: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat bacaan: $e');
    }
  }
}

/// Merepresentasikan satu kitab Alkitab.
class BibleBook {
  final String abbr;
  final int chapter; // Jumlah total bab
  final String name;
  final String testament; // 'old' atau 'new'

  BibleBook({
    required this.abbr,
    required this.chapter,
    required this.name,
    required this.testament,
  });

  /// Membuat instance BibleBook dari Map (JSON).
  factory BibleBook.fromJson(Map<String, dynamic> json) {
    final int bookNumber = json['no'] ?? 0;
    
    // Menentukan Perjanjian berdasarkan nomor urut kitab (konvensi umum)
    final String testament;
    if (bookNumber > 0 && bookNumber <= 39) {
      testament = 'old'; // Perjanjian Lama
    } else if (bookNumber > 39 && bookNumber <= 66) {
      testament = 'new'; // Perjanjian Baru
    } else {
      testament = 'other';
    }

    return BibleBook(
      abbr: json['abbr'] ?? '',
      chapter: json['chapter'] ?? 0,
      name: json['name'] ?? '',
      testament: testament,
    );
  }
}

/// Merepresentasikan satu pasal Alkitab penuh (kumpulan ayat).
class BiblePassage {
  final String book; // Nama kitab
  final int chapter; // Nomor pasal
  final List<BibleVerse> verses; // Daftar ayat

  BiblePassage({
    required this.book,
    required this.chapter,
    required this.verses,
  });

  /// Membuat instance BiblePassage dari Map (JSON).
  factory BiblePassage.fromJson(Map<String, dynamic> json) {
    var versesList = <BibleVerse>[];
    
    if (json['data'] != null && json['data']['verses'] != null) {
      versesList = (json['data']['verses'] as List)
          .map((v) => BibleVerse.fromJson(v))
          .toList();
    }

    return BiblePassage(
      book: json['data']?['book']?['name'] ?? '',
      chapter: json['data']?['chapter'] ?? 0, 
      verses: versesList,
    );
  }
}

/// Merepresentasikan satu ayat atau elemen konten dalam pasal.
class BibleVerse {
  final int verse; // Nomor ayat
  final String text; // Konten teks
  final String type; // Tipe konten (e.g., 'content', 'title', 'heading')

  BibleVerse({
    required this.verse,
    required this.text,
    required this.type,
  });

  /// Membuat instance BibleVerse dari Map (JSON).
  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      verse: json['verse'] ?? 0,
      text: json['content'] ?? '',
      type: json['type'] ?? 'content', 
    );
  }
}
import 'dart:developer'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/services/bible_service.dart'; 
import 'package:projek_akhir_katolik/utils/constants.dart'; 

/// Layar utama untuk membaca Alkitab. 
/// Mengelola tampilan daftar kitab, pemilihan bab, dan pemuatan isi pasal.
class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final BibleService _bibleService = BibleService();
  late Future<List<BibleBook>> _booksFuture;
  
  BibleBook? _selectedBook;
  int? _selectedChapter;
  BiblePassage? _currentPassage;
  bool _isLoadingPassage = false;

  @override
  void initState() {
    super.initState();
    _booksFuture = _bibleService.getBookList();
    log('Loading bible books...');
  }

  /// Memuat isi pasal (passage) dari API berdasarkan singkatan kitab dan nomor bab.
  void _loadPassage(String bookAbbr, int chapter) async {
    log('Loading passage: $bookAbbr chapter $chapter');
    setState(() {
      _isLoadingPassage = true;
      _selectedChapter = chapter;
    });

    try {
      final passage = await _bibleService.getPassage(bookAbbr, chapter);
      if (mounted) {
        setState(() {
          _currentPassage = passage;
          _isLoadingPassage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPassage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat bacaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Menampilkan modal sheet yang berisi tab Perjanjian Lama dan Baru untuk memilih kitab.
  void _showBookSelector(List<BibleBook> books) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Warna Asli
            colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Warna Asli
                color: AppColors.white10,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Pilih Kitab',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // Tab Bar untuk Perjanjian Lama dan Baru
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Perjanjian Lama'),
                        Tab(text: 'Perjanjian Baru'),
                      ],
                    ),
                    // Tab Bar View menampilkan daftar kitab yang difilter
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildBookList(
                            books.where((b) => b.testament == 'old').toList(),
                          ),
                          _buildBookList(
                            books.where((b) => b.testament == 'new').toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun ListView dari daftar kitab yang difilter.
  Widget _buildBookList(List<BibleBook> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            // Warna Asli
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Warna Asli
                color: AppColors.white20,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              book.name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${book.chapter} Bab',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white70,
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedBook = book;
                _selectedChapter = null;
                _currentPassage = null;
              });
              // Membuka modal pemilihan bab setelah memilih kitab
              _showChapterSelector(book);
            },
          ),
        );
      },
    );
  }

  /// Menampilkan modal sheet untuk memilih Bab dari kitab yang dipilih.
  void _showChapterSelector(BibleBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Warna Asli
            colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Warna Asli
                color: AppColors.white10,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_list_numbered, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Bab',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          book.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Chapter Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: book.chapter,
                itemBuilder: (context, index) {
                  final chapterNum = index + 1;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // Memuat isi pasal ketika bab dipilih
                      _loadPassage(book.abbr, chapterNum); 
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        // Warna Asli
                        color: AppColors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          // Warna Asli
                          color: AppColors.white20,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$chapterNum',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// WIDGET TAMPILAN KONTEN UTAMA
  Widget _buildAllBooksView(List<BibleBook> books) {
    final oldTestamentBooks = books.where((b) => b.testament == 'old').toList();
    final newTestamentBooks = books.where((b) => b.testament == 'new').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Text(
          'Perjanjian Lama',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...oldTestamentBooks.map((book) => _buildBookCard(book)),
        
        const SizedBox(height: 24),
        
        Text(
          'Perjanjian Baru',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...newTestamentBooks.map((book) => _buildBookCard(book)),
        
        const SizedBox(height: 16),
      ],
    );
  }

  /// Widget kartu yang menampilkan nama dan jumlah bab dari sebuah kitab.
  Widget _buildBookCard(BibleBook book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        // Warna Asli
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.book_rounded,
          color: Colors.white70,
          size: 20,
        ),
        title: Text(
          book.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${book.chapter} Bab',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white70,
        ),
        onTap: () {
          setState(() {
            _selectedBook = book;
          });
          _showChapterSelector(book);
        },
      ),
    );
  }

  /// Widget untuk menampilkan isi pasal (Ayat dan Judul) yang telah dimuat.
  Widget _buildPassageView(BiblePassage passage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Warna Asli
        color: AppColors.white15,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Warna Asli
          color: AppColors.white20,
        ),
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: passage.verses.length,
          itemBuilder: (context, index) {
            final verse = passage.verses[index];

            if (verse.type == 'title' || verse.type == 'heading') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 4.0),
                child: Text(
                  verse.text, 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18, 
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic, 
                  ),
                ),
              );
            } else {

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${verse.verse} ', 
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: verse.text,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // Warna Asli
                        color: AppColors.white20,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Alkitab',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Warna Asli
                  color: AppColors.white15,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    // Warna Asli
                    color: AppColors.white20,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<List<BibleBook>>(
                        future: _booksFuture,
                        builder: (context, snapshot) {
                          bool hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                          
                          return GestureDetector(
                            onTap: hasData 
                                ? () => _showBookSelector(snapshot.data!)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                // Warna Asli
                                color: AppColors.white20,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedBook?.name ?? 'Pilih Kitab',
                                    style: GoogleFonts.poppins(
                                      color: hasData ? Colors.white : Colors.white54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: hasData ? Colors.white : Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedBook != null) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _showChapterSelector(_selectedBook!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            // Warna Asli
                            color: AppColors.white20,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedChapter != null
                                    ? 'Bab $_selectedChapter'
                                    : 'Bab',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<BibleBook>>(
                  future: _booksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat daftar kitab',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (_isLoadingPassage) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (_currentPassage != null) {
                      return _buildPassageView(_currentPassage!); 
                    }

                    // Default view - show all books (setelah data kitab dimuat)
                    return _buildAllBooksView(snapshot.data ?? []);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
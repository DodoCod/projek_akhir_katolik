import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/models/liturgical_day.dart';
import 'package:projek_akhir_katolik/services/liturgy_service.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<LiturgicalDay> _liturgyFuture;
  final LiturgyService _liturgyService = LiturgyService();
  DateTime _selectedDate = DateTime.now();
  DateTime _displayDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _liturgyFuture = _liturgyService.getTodaysLiturgy();
    _displayDate = DateTime.now();
  }

  void _loadLiturgyForDate(DateTime date) {
    setState(() {
      _displayDate = date; 
      _liturgyFuture = _liturgyService.getLiturgyForDate(date); 
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get days in current month
  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final days = <DateTime>[];
    
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }
    
    return days;
  }

  // Get start day of week (padding for calendar)
  int _getStartDayOfWeek(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }

  Widget _buildCalendarView() {
    final daysInMonth = _getDaysInMonth(_selectedDate);
    final startDay = _getStartDayOfWeek(_selectedDate);
    final today = DateTime.now();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white15,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white20,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month - 1,
                    );
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: startDay + daysInMonth.length,
            itemBuilder: (context, index) {
              if (index < startDay) {
                return const SizedBox();
              }
              
              final dayIndex = index - startDay;
              final date = daysInMonth[dayIndex];
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              final isSelected = date.day == _displayDate.day &&
                  date.month == _displayDate.month &&
                  date.year == _displayDate.year;
              
              return GestureDetector(
                onTap: () {
                  _loadLiturgyForDate(date); 
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.white40
                        : isToday
                            ? AppColors.white20
                            : AppColors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : isToday
                            ? Border.all(color: Colors.white70, width: 1.5)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiturgyCard(LiturgicalDay liturgyData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white15,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white20,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.church_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayDate.day == DateTime.now().day
                            ? 'Liturgi Hari Ini'
                            : 'Liturgi Pilihan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_displayDate),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Judul Peringatan
            Text(
              liturgyData.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Info Warna Liturgi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.palette_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Warna Liturgi: ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: liturgyData.liturgicalColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    liturgyData.color,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),            
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white20,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Beranda',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: FutureBuilder<LiturgicalDay>(
                  future: _liturgyFuture, 
                  builder: (context, snapshot) {
                    // Loading State
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    // Error State
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white20,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat data',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Success State
                    if (snapshot.hasData) {
                      return RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: const Color(0xFF4A5568),
                        onRefresh: () async {
                          setState(() {
                            // Refresh akan selalu kembali ke hari ini
                            _displayDate = DateTime.now();
                            _selectedDate = DateTime.now();
                            _liturgyFuture = _liturgyService.getTodaysLiturgy();
                          });
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              // Calendar View
                              _buildCalendarView(),
                              const SizedBox(height: 16),
                              // Today's Liturgy
                              _buildLiturgyCard(snapshot.data!),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Center(
                      child: Text(
                        'Tidak ada data',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    );
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
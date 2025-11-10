import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/utils/constants.dart'; 

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  final String _staticImpression = 
      'Cara mengajar Pak Bagus sangat santai dan mudah diikuti. Beliau sering memberikan contoh kehidupan nyata yang relevan, sehingga materi Mobile Programming yang sulit jadi terasa "nyambung". Interaksi di kelas juga sangat hidup!';
  final String _staticSuggestion = 
      'Mungkin akan sangat bermanfaat jika Pak Bagus dapat lebih banyak melakukan live code (pemrograman langsung) di kelas saat menjelaskan suatu konsep, bukan sekadar menjelaskan teori dari slide. Sesi live code sederhana ini, meskipun ada jadwal praktikum, akan sangat membantu menambah insight praktis dan pemahaman alur kerja koding yang sebenarnya.';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saran & Kesan Dosen', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.gradientStart,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: <Widget>[
            // KARTU 1: KESAN POSITIF 
            _buildFeedbackCard(
              title: 'Kesan Umum (Pengalaman Mengajar)',
              icon: Icons.thumb_up_alt_rounded,
              content: _staticImpression,
              color: AppColors.success,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // KARTU 2: SARAN PENINGKATAN 
            _buildFeedbackCard(
              title: 'Saran Peningkatan (Metode Pembelajaran)',
              icon: Icons.lightbulb_outline,
              content: _staticSuggestion,
              color: AppColors.purpleAccent,
            ),
            const SizedBox(height: AppDimensions.paddingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.white50), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded( // WIDGET PENTING UNTUK MENGATASI OVERFLOW
                child: Text(
                  title,
                  style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis, 
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          const Divider(color: Colors.white24, height: 1), 
          const SizedBox(height: AppDimensions.paddingSmall),
          
          Text(
            content,
            style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
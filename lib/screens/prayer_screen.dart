import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final List<Prayer> _prayers = [
    Prayer(
      id: 'angelus',
      title: 'Angelus',
      category: 'Doa Harian',
      content: '''V. Malaikat Tuhan menyampaikan kabar kepada Maria.
R. Dan ia mengandung dari Roh Kudus.

Salam Maria...

V. Sesungguhnya aku ini hamba Tuhan.
R. Terjadilah padaku menurut perkataan-Mu.

Salam Maria...

V. Sabda telah menjadi daging.
R. Dan Ia telah tinggal di antara kita.

Salam Maria...

V. Doakanlah kami ya Bunda Allah yang Kudus.
R. Supaya kami dapat menerima janji Kristus.

Marilah berdoa:
Ya Allah, berkenanlah mencurahkan rahmat-Mu ke dalam hati kami; supaya kami yang telah mengenal penjelmaan Kristus Putra-Mu oleh pemberitaan malaikat, oleh sengsara dan salib-Nya diantar kepada kemuliaan kebangkitan-Nya. Demi Kristus Tuhan kami. 
R. Amin.''',
      isAngelus: true,
    ),
    Prayer(
      id: 'bapa_kami',
      title: 'Bapa Kami',
      category: 'Doa Pokok',
      content: '''Bapa kami yang ada di surga,
Dimuliakanlah nama-Mu,
Datanglah kerajaan-Mu,
Jadilah kehendak-Mu
di atas bumi seperti di dalam surga.

Berilah kami rezeki pada hari ini,
dan ampunilah kesalahan kami,
seperti kami pun mengampuni
yang bersalah kepada kami;

dan janganlah masukkan kami ke dalam pencobaan,
tetapi bebaskanlah kami dari yang jahat.
Amin.''',
    ),
    Prayer(
      id: 'salam_maria',
      title: 'Salam Maria',
      category: 'Doa Pokok',
      content: '''Salam Maria, penuh rahmat,
Tuhan sertamu.
Terpujilah engkau di antara wanita
dan terpujilah buah tubuhmu, Yesus.

Santa Maria, Bunda Allah,
doakanlah kami yang berdosa ini,
sekarang dan waktu kami mati.
Amin.''',
    ),
    Prayer(
      id: 'kemuliaan',
      title: 'Kemuliaan',
      category: 'Doa Pokok',
      content: '''Kemuliaan kepada Bapa dan Putra dan Roh Kudus,
seperti pada permulaan, sekarang, selalu,
dan sepanjang segala abad.
Amin.''',
    ),
    Prayer(
      id: 'syahadat_para_rasul',
      title: 'Syahadat Para Rasul',
      category: 'Doa Iman',
      content: '''Aku percaya akan Allah, Bapa yang Mahakuasa, pencipta langit dan bumi.

Dan akan Yesus Kristus, Putra-Nya yang tunggal, Tuhan kita, yang dikandung dari Roh Kudus, dilahirkan oleh Perawan Maria, yang menderita sengsara dalam pemerintahan Pontius Pilatus, disalibkan, wafat, dan dimakamkan, yang turun ke tempat penantian, pada hari ketiga bangkit dari antara orang mati, yang naik ke surga, duduk di sisi kanan Allah Bapa yang Mahakuasa, dari situ Ia akan datang mengadili orang yang hidup dan yang mati.

Aku percaya akan Roh Kudus, Gereja Katolik yang kudus, persekutuan para kudus, pengampunan dosa, kebangkitan badan, kehidupan kekal. 
Amin.''',
    ),
    Prayer(
      id: 'malaikat_tuhan',
      title: 'Malaikat Tuhan',
      category: 'Doa Maria',
      content: '''Malaikat Tuhan memberitakan kepada Maria,
dan ia mengandung dari Roh Kudus.

Salam Maria...

"Sesungguhnya aku ini adalah hamba Tuhan,
terjadilah padaku menurut perkataan-Mu."

Salam Maria...

Dan Sabda telah menjadi daging,
dan tinggal di antara kita.

Salam Maria...

Doakanlah kami, ya Bunda Allah yang Kudus,
supaya kami dapat menerima janji Kristus.

Marilah berdoa:
Ya Allah, berkenanlah mencurahkan rahmat-Mu ke dalam hati kami, supaya kami yang telah mengenal penjelmaan Kristus Putra-Mu dengan pemberitaan malaikat, oleh sengsara dan salib-Nya diantar kepada kemuliaan kebangkitan. Demi Kristus Tuhan kami.
Amin.''',
    ),
    Prayer(
      id: 'rosario',
      title: 'Doa Rosario',
      category: 'Doa Maria',
      content: '''CARA BERDOA ROSARIO:

1. Membuat Tanda Salib
2. Syahadat Para Rasul (pada salib)
3. Bapa Kami (pada manik pertama)
4. 3x Salam Maria (pada 3 manik berikutnya)
5. Kemuliaan (setelah 3 Salam Maria)

Untuk setiap misteri (ada 5 misteri per waktu):
- Bapa Kami (1x)
- Salam Maria (10x) sambil merenungkan misteri
- Kemuliaan (1x)
- Doa Fatima (1x): "Ya Yesus, ampunilah dosa-dosa kami..."

6. Setelah 5 misteri, berdoa Salam Bunda Allah
7. Ditutup dengan Tanda Salib

MISTERI GEMBIRA (Senin & Sabtu):
1. Maria menerima kabar gembira
2. Maria mengunjungi Elisabeth
3. Yesus dilahirkan di Betlehem
4. Yesus dipersembahkan di Bait Allah
5. Yesus ditemukan di Bait Allah

MISTERI SEDIH (Selasa & Jumat):
1. Yesus berdoa di Taman Getsemani
2. Yesus disiksa
3. Yesus dimahkotai duri
4. Yesus memanggul salib
5. Yesus wafat di salib

MISTERI MULIA (Rabu & Minggu):
1. Yesus bangkit dari mati
2. Yesus naik ke surga
3. Roh Kudus turun atas para Rasul
4. Maria diangkat ke surga
5. Maria dimahkotai di surga

MISTERI TERANG (Kamis):
1. Yesus dibaptis di Sungai Yordan
2. Yesus mengadakan mukjizat di Kana
3. Yesus mewartakan Kerajaan Allah
4. Yesus dimuliakan di Gunung Tabor
5. Yesus menetapkan Ekaristi''',
    ),
    Prayer(
      id: 'sebelum_makan',
      title: 'Doa Sebelum Makan',
      category: 'Doa Sehari-hari',
      content: '''Berkatilah ya Tuhan,
kami dan makanan ini
yang kami terima dari kemurahan-Mu,
Demi Kristus Tuhan kami.
Amin.''',
    ),
    Prayer(
      id: 'sesudah_makan',
      title: 'Doa Sesudah Makan',
      category: 'Doa Sehari-hari',
      content: '''Kami bersyukur kepada-Mu
ya Allah yang mahakuasa,
atas segala nikmat-Mu,
yang hidup dan berkuasa,
sepanjang segala masa.
Amin.''',
    ),
    Prayer(
      id: 'pagi',
      title: 'Doa Pagi',
      category: 'Doa Harian',
      content: '''Ya Yesus, melalui hati Maria yang Immaculata,
aku mempersembahkan kepada-Mu
doa, pekerjaan, suka, dan dukaku
pada hari ini untuk segala maksud hati-Mu yang mahakudus.

Dalam persatuan dengan kurban Ekaristi
yang tak berkesudahan di seluruh dunia,
aku mempersembahkan hari ini khusus
untuk niat Bapa Suci bulan ini.
Amin.''',
    ),
    Prayer(
      id: 'malam',
      title: 'Doa Malam',
      category: 'Doa Harian',
      content: '''Ya Tuhan Yesus Kristus,
aku bersyukur atas rahmat dan berkat-Mu
yang telah Kau limpahkan kepadaku
sepanjang hari ini.

Ampunilah segala dosa dan kesalahanku.
Berikanlah aku tidur yang tenang
di bawah perlindungan-Mu.

Lindungilah aku dan keluargaku
dari segala bahaya dan kejahatan.

Terpujilah Engkau ya Tuhan,
kini dan sepanjang masa.
Amin.''',
    ),
  ];

  List<String> get _categories {
    return _prayers.map((p) => p.category).toSet().toList();
  }

  void _showPrayerDetail(Prayer prayer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrayerDetailScreen(prayer: prayer),
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
              // App Bar
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
                        Icons.church_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Doa',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = _categories[categoryIndex];
                    final categoryPrayers = _prayers
                        .where((p) => p.category == category)
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ...categoryPrayers.map((prayer) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.white15,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.white30,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: prayer.isAngelus
                                      ? AppColors.amber30
                                      : AppColors.white30,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  prayer.isAngelus
                                      ? Icons.notifications_active_rounded
                                      : Icons.menu_book_rounded,
                                  color: prayer.isAngelus
                                      ? Colors.amber
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                prayer.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: prayer.isAngelus
                                  ? Text(
                                      'Notifikasi: 06:00, 12:00, 18:00',
                                      style: GoogleFonts.poppins(
                                        color: Colors.amber[200],
                                        fontSize: 11,
                                      ),
                                    )
                                  : null,
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                              onTap: () => _showPrayerDetail(prayer),
                            ),
                          );
                        }),
                      ],
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

// Prayer Model
class Prayer {
  final String id;
  final String title;
  final String category;
  final String content;
  final bool isAngelus;

  Prayer({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.isAngelus = false,
  });
}

// Prayer Detail Screen
class PrayerDetailScreen extends StatelessWidget {
  final Prayer prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

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
              // App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prayer.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white15,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.white30,
                      ),
                    ),
                    child: Text(
                      prayer.content,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
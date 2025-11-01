import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/models/user_model.dart'; 
import 'package:projek_akhir_katolik/services/auth_service.dart';
import 'package:projek_akhir_katolik/services/world_time_service.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';
import 'package:projek_akhir_katolik/screens/premium/go_premium_screen.dart';

/// Layar utama untuk menampilkan jam dunia real-time dan konverter zona waktu.
/// Fitur konverter dilindungi oleh status Premium.
class WorldTimeScreen extends StatefulWidget {
  const WorldTimeScreen({super.key});

  @override
  State<WorldTimeScreen> createState() => _WorldTimeScreenState();
}

class _WorldTimeScreenState extends State<WorldTimeScreen> {
  final AuthService _authService = AuthService();

  // Data pengguna dan status
  User? _currentUser;
  bool _isLoading = true;

  // Timezone data
  TimezoneInfo? _jakartaTime;
  TimezoneInfo? _vaticanTime;

  // Converter data
  String _selectedTimezone = ApiConstants.vaticanTimezone;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  String _convertedTime = '—';
  final String _targetTimezone = 'Asia/Jakarta';
  String? _converterError; 

  // Timer untuk auto-update jam
  Timer? _clockTimer;

  // Vatican Events (simulasi)
  final List<Map<String, dynamic>> _vaticanEvents = [
    {'title': 'Audiensi Umum Paus', 'day': 'Thursday', 'hour': 9, 'minute': 0, 'time_display': '09:00'},
    {'title': 'Doa Angelus', 'day': 'Monday', 'hour': 12, 'minute': 0, 'time_display': '12:00'},
    {'title': 'Misa Harian', 'day': 'Wednesday', 'hour': 7, 'minute': 0, 'time_display': '07:00'},
  ];

  /// Getter untuk memeriksa apakah pengguna memiliki keanggotaan Premium aktif.
  bool get isPremium => _currentUser?.isPremiumActive ?? false;

  @override
  void initState() {
    super.initState();
    if (!WorldTimeService.getAvailableTimezones().contains(_selectedTimezone)) {
        _selectedTimezone = 'Asia/Jakarta';
    }
    _initialize();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  /// Memuat data awal: user, timezone offset, dan memulai konversi/timer.
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _converterError = null;
    });

    _currentUser = await _authService.getLoggedInUser();
    
    await _fetchTimezones();

    await _convertTime();
    
    _startClockTimer();

    setState(() => _isLoading = false);
  }

  /// Mengambil data offset waktu Jakarta dan Vatikan dari service/API.
  Future<void> _fetchTimezones() async {
    try {
      final timezones = await WorldTimeService.getMultipleTimezones([
        'Asia/Jakarta',
        ApiConstants.vaticanTimezone,
      ]);

      _jakartaTime = timezones['Asia/Jakarta'];
      _vaticanTime = timezones[ApiConstants.vaticanTimezone];
    } catch (e) {
      // Error fetch ditangani di service, kita biarkan saja _jakartaTime/_vaticanTime = null
    }
  }

  /// Memulai timer yang memperbarui jam dunia real-time setiap detik.
  void _startClockTimer() {
    _clockTimer?.cancel();

    if (_jakartaTime == null || _vaticanTime == null) {
      return; 
    }
    
    final jakartaOffsetSeconds = _jakartaTime!.utcOffset;
    final vaticanOffsetSeconds = _vaticanTime!.utcOffset;

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final nowUtc = DateTime.now().toUtc(); 

          final jakartaOffsetDuration = Duration(seconds: jakartaOffsetSeconds);
          final jakartaTimeNow = nowUtc.add(jakartaOffsetDuration);
          _jakartaTime = _jakartaTime!.copyWithDateTime(jakartaTimeNow);

          final vaticanOffsetDuration = Duration(seconds: vaticanOffsetSeconds);
          final vaticanTimeNow = nowUtc.add(vaticanOffsetDuration);
          _vaticanTime = _vaticanTime!.copyWithDateTime(vaticanTimeNow);
        });
      }
    });
  }

  /// Menangani logika konversi waktu dari input pengguna ke waktu target (Jakarta).
  Future<void> _convertTime() async {
    if (!isPremium) { // Jika tidak premium, set lock state dan KELUAR
      setState(() {
        _convertedTime = '(Premium Only)';
        _converterError = null;
      });
      return; 
    }

    try {
      final now = DateTime.now();
      final sourceDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final converted = await WorldTimeService.convertTimeWithAPI(
        sourceDateTime: sourceDateTime,
        sourceZone: _selectedTimezone,
        targetZone: _targetTimezone,
      );

      if (converted != null) {
        setState(() {
          _convertedTime = WorldTimeService.formatTime(converted);
          _converterError = null;
        });
      } else {
        setState(() {
          _convertedTime = 'Error';
          _converterError = 'Konversi gagal total.';
        });
      }
    } catch (e) {
      setState(() {
        _convertedTime = 'Error';
        _converterError = 'Gagal konversi (Jaringan/Data invalid).';
      });
    }
  }

  /// Menampilkan dialog konfirmasi dan navigasi ke layar upgrade premium.
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.gradientStart,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Text('Fitur Premium', style: GoogleFonts.poppins(color: AppColors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur konversi zona waktu hanya tersedia untuk pengguna Premium.',
              style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Konversi waktu unlimited'),
            _buildFeatureItem('Pilih dari 30+ zona waktu'),
            _buildFeatureItem('Real-time dari World Time API'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Nanti', style: GoogleFonts.poppins(color: AppColors.white50)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoPremiumScreen()),
              ).then((value) {
                if (value == true) _initialize();
              });
            },
            icon: const Icon(Icons.lock_open),
            label: Text('Upgrade', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pembantu untuk menampilkan item fitur dalam dialog premium.
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// Menampilkan modal sheet untuk memilih zona waktu sumber.
  void _showTimezoneSelector(List<String> timezones) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.gradientStart,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Zona Waktu', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: timezones.length,
                  itemBuilder: (context, index) {
                    final tz = timezones[index];
                    final isSelected = tz == _selectedTimezone;

                    return ListTile(
                      title: Text(
                        WorldTimeService.getTimezoneDisplayName(tz),
                        style: GoogleFonts.poppins(
                          color: isSelected ? AppColors.purpleAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.purpleAccent) : null,
                      onTap: () {
                        setState(() => _selectedTimezone = tz);
                        Navigator.pop(context);
                        _convertTime();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }


  /// WIDGETS UTAMA
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
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : RefreshIndicator(
                        onRefresh: _initialize,
                        color: Colors.white,
                        backgroundColor: AppColors.purpleAccent,
                        child: CustomScrollView(
                          slivers: [
                            _buildAppBar(isPremium),
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                            _buildWorldClocks(),
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                            _buildVaticanEvents(isPremium),
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                            _buildTimezoneConverter(isPremium),
                            const SliverToBoxAdapter(child: SizedBox(height: 40)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menampilkan loading state saat data sedang dimuat.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          const SizedBox(height: 16),
          Text('Memuat data...', style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  /// Membangun custom AppBar yang menampilkan status Premium/Lock.
  Widget _buildAppBar(bool isPremium) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Waktu Dunia', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Text('Konversi Zona Waktu', style: GoogleFonts.poppins(color: AppColors.white50, fontSize: 12)),
        ],
      ),
      actions: [
        if (isPremium)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amber20,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('Premium', style: GoogleFonts.poppins(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.amber),
            onPressed: _showPremiumDialog,
          ),
      ],
    );
  }

  /// Membangun daftar jam dunia real-time untuk Jakarta dan Vatikan.
  Widget _buildWorldClocks() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jam Dunia Real-time', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Auto-update setiap detik', style: GoogleFonts.poppins(color: AppColors.white50, fontSize: 14)),
            const SizedBox(height: 16),
            _buildClockCard('🇮🇩', 'Jakarta', _jakartaTime, true),
            const SizedBox(height: 12),
            _buildClockCard('🇻🇦', 'Vatikan', _vaticanTime, false),
          ],
        ),
      ),
    );
  }

  /// Kartu tunggal yang menampilkan waktu dan offset zona tertentu.
  Widget _buildClockCard(String flag, String title, TimezoneInfo? info, bool highlight) {
    final isAngelus = info != null && WorldTimeService.isAngelusTime(info.datetime);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: highlight
            ? LinearGradient(colors: [AppColors.purpleAccent.withAlpha(77), AppColors.purpleAccentDark.withAlpha(77)])
            : null,
        color: highlight ? null : AppColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAngelus ? Colors.amber : (highlight ? AppColors.purpleAccent : AppColors.white20),
          width: isAngelus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                if (info != null) Text(info.utcOffsetString, style: GoogleFonts.poppins(color: AppColors.white50, fontSize: 12)),
              ],
            ),
          ),
          if (info != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  WorldTimeService.formatTimeWithSeconds(info.datetime),
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (isAngelus)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amber30,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text('Angelus', style: GoogleFonts.poppins(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// Membangun daftar acara Vatikan (simulasi) tanpa konversi waktu.
  Widget _buildVaticanEvents(bool isPremium) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.white20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.amber20,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🇻🇦', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Acara Vatikan', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Informasi Waktu Lokal Vatikan', style: GoogleFonts.poppins(color: AppColors.white50, fontSize: 12)), 
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white24),
              ..._vaticanEvents.map((event) => _buildVaticanEventCard(event, isPremium)),
            ],
          ),
        ),
      ),
    );
  }

  /// Kartu tunggal untuk menampilkan detail acara Vatikan (Waktu Lokal).
  Widget _buildVaticanEventCard(Map<String, dynamic> event, bool isPremium) {
    final vaticanTime = event['time_display'];
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✝️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event['title'],
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.white50, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${event['day']}, $vaticanTime (Waktu Vatikan)',
                    style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 13),
                  ),
                ],
              ),
              
              // Menampilkan hanya Waktu Lokal Vatikan (Tanpa konversi)
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.purpleAccent, size: 18),
                  const SizedBox(width: 8),
                  Text('Waktu Lokal Vatikan:', style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccent.withAlpha(77),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      vaticanTime, // Tampilkan waktu Vatikan aslinya
                      style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
        if (event != _vaticanEvents.last) const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  /// Membangun konverter zona waktu yang interaktif dan dilindungi fitur Premium.
  Widget _buildTimezoneConverter(bool isPremium) {
    final timezones = WorldTimeService.getAvailableTimezones();

    if (!timezones.contains(_selectedTimezone)) {
        _selectedTimezone = timezones.first;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(isPremium ? 38 : 26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPremium ? AppColors.white20 : AppColors.amber30,
              width: isPremium ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz, color: isPremium ? Colors.white : Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text('Konverter Zona Waktu', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (!isPremium) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.lock, color: Colors.amber, size: 16),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              // --- Input Fields (Tergantung Premium) ---
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isPremium
                          ? () async {
                              final time = await showTimePicker(context: context, initialTime: _selectedTime);
                              if (time != null) {
                                setState(() => _selectedTime = time);
                                await _convertTime();
                              }
                            }
                          : _showPremiumDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.white20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Waktu Sumber:', style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: isPremium ? Colors.white : Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.robotoMono(color: isPremium ? Colors.white : Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: isPremium ? () => _showTimezoneSelector(timezones) : _showPremiumDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.white20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zona Sumber:', style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    WorldTimeService.getTimezoneDisplayName(_selectedTimezone).split(' ').first,
                                    style: GoogleFonts.poppins(color: isPremium ? Colors.white : Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: isPremium ? AppColors.white50 : Colors.amber),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(child: Icon(Icons.arrow_downward_rounded, size: 32, color: isPremium ? AppColors.purpleAccent : Colors.amber)),
              const SizedBox(height: 20),

              // HASIL KONVERSI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPremium ? AppColors.purpleAccent.withAlpha(51) : AppColors.amber10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isPremium ? AppColors.purpleAccent : Colors.amber),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Waktu Konversi ($_targetTimezone):', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    
                    if (!isPremium)
                        FittedBox( 
                          child: Text(
                            '(Premium Only)', 
                            style: GoogleFonts.robotoMono(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                        )
                    else if (_convertedTime == 'Error' && _converterError != null)
                        Text(
                            _converterError!, 
                            style: GoogleFonts.poppins(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.bold)
                        )
                    else 
                        Text(_convertedTime, style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              if (!isPremium) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fitur konversi unlimited hanya untuk Premium',
                        style: GoogleFonts.poppins(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showPremiumDialog,
                    icon: const Icon(Icons.lock_open),
                    label: Text('Unlock Premium', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
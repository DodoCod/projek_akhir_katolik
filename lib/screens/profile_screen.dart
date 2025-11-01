import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/models/user_model.dart';
import 'package:projek_akhir_katolik/screens/auth/login_screen.dart';
import 'package:projek_akhir_katolik/services/auth_service.dart';
import 'package:projek_akhir_katolik/services/notification_service.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';
import 'package:projek_akhir_katolik/screens/feedback_screen.dart';
import 'package:projek_akhir_katolik/screens/premium/go_premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getLoggedInUser();
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout', style: GoogleFonts.poppins()),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await NotificationService.cancelAllNotifications();
      await _authService.logoutUser();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  void _handlePremiumNavigation(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoPremiumScreen()),
    );

    if (result == true) {
      setState(() {
        _userFuture = _authService.getLoggedInUser();
      });
    }
  }

  void _downgradeSubscription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi', style: GoogleFonts.poppins()),
        content: Text(
          'Anda yakin ingin membatalkan langganan premium? Notifikasi Angelus akan dinonaktifkan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Ya, Batalkan', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      )
    );

    if (confirm != true) return;

    // Panggil service untuk downgrade
    final success = await _authService.downgradeCurrentUserFromPremium();

    if (mounted) {
      if (success) {
        await NotificationService.cancelAngelusNotifications(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Langganan premium telah dibatalkan.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        // Muat ulang data user untuk me-refresh UI
        setState(() {
          _userFuture = _authService.getLoggedInUser();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan langganan.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // FUNGSI HELPER UNTUK NOTIFIKASI (Hapus showTestNotification)
  void _scheduleAngelus() async {
    await NotificationService.scheduleAngelusNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi Angelus telah dijadwalkan.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cancelAngelus() async {
    await NotificationService.cancelAngelusNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi Angelus telah dihentikan.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _checkPending() async {
    final pending = await NotificationService.getPendingNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pending.length} notifikasi terjadwal. Cek konsol debug.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.purple,
        ),
      );
    }
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
          child: FutureBuilder<User?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data user',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final user = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Header Section
                          Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                // Profile Picture
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white30,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.white20,
                                    backgroundImage: user.profileImagePath != null
                                        ? FileImage(File(user.profileImagePath!))
                                        : null,
                                    child: user.profileImagePath == null
                                        ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: AppColors.white60,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Username
                                Text(
                                  user.username,
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Chip Status Premium
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isPremiumActive 
                                        ? AppColors.amber30 
                                        : AppColors.white20,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    user.membershipTier, 
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: user.isPremiumActive ? Colors.amber : AppColors.white90,
                                      fontWeight: user.isPremiumActive ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // BAGIAN NOTIFIKASI
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: AppColors.white15,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white20,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        user.isPremiumActive ? Icons.notifications_active_rounded : Icons.lock_outline_rounded, 
                                        color: user.isPremiumActive ? Colors.cyan : Colors.white70, 
                                        size: 20
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Notifikasi Angelus (Premium)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1, color: AppColors.white10),

                                // Tombol Jadwalkan Angelus (Premium)
                                _buildMenuItem(
                                  icon: Icons.calendar_today_rounded,
                                  title: 'Jadwalkan Angelus',
                                  iconColor: user.isPremiumActive ? Colors.green : Colors.grey,
                                  trailingIcon: user.isPremiumActive ? null : Icons.lock,
                                  onTap: () {
                                    if (user.isPremiumActive) {
                                      _scheduleAngelus();
                                    } else {
                                      _handlePremiumNavigation(user); // Buka Paywall
                                    }
                                  },
                                ),
                                Divider(height: 1, color: AppColors.white10),
                                
                                // Tombol Hentikan Angelus (Premium)
                                _buildMenuItem(
                                  icon: Icons.notifications_off_outlined,
                                  title: 'Hentikan Notifikasi Angelus',
                                  iconColor: user.isPremiumActive ? Colors.orange : Colors.grey,
                                  trailingIcon: user.isPremiumActive ? null : Icons.lock,
                                  onTap: () {
                                    if (user.isPremiumActive) {
                                      _cancelAngelus();
                                    } else {
                                      _handlePremiumNavigation(user); // Buka Paywall
                                    }
                                  },
                                ),
                                Divider(height: 1, color: AppColors.white10),
                                
                                // Tombol Cek Notifikasi (Premium)
                                _buildMenuItem(
                                  icon: Icons.list_alt_rounded,
                                  title: 'Cek Notifikasi (di Konsol)',
                                  iconColor: user.isPremiumActive ? Colors.purpleAccent : Colors.grey,
                                  trailingIcon: user.isPremiumActive ? null : Icons.lock,
                                  onTap: () {
                                    if (user.isPremiumActive) {
                                      _checkPending();
                                    } else {
                                      _handlePremiumNavigation(user); // Buka Paywall
                                    }
                                  },
                                ),

                                // Tombol Batal Berlangganan (Hanya jika premium)
                                if(user.isPremiumActive) ...[
                                  Divider(
                                    height: 1,
                                    color: AppColors.white10,
                                  ),
                                  _buildMenuItem(
                                    icon: Icons.lock_clock,
                                    title: 'Batalkan Berlangganan',
                                    iconColor: Colors.redAccent,
                                    onTap: _downgradeSubscription,
                                    isDestructive: true,
                                  ),
                                ]
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // BAGIAN PENGATURAN (Saran & Logout)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: AppColors.white15,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white20,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  icon: Icons.lightbulb_outline,
                                  title: 'Saran dan Kesan',
                                  iconColor: Colors.amber,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                                    );
                                  },
                                ),
                                Divider(
                                  height: 1,
                                  color: AppColors.white10,
                                ),
                                _buildMenuItem(
                                  icon: Icons.exit_to_app,
                                  title: 'Logout',
                                  iconColor: Colors.red,
                                  onTap: () => _logout(context),
                                  isDestructive: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 60),

                          // App Info
                          Text(
                            AppStrings.appName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.white50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Versi ${AppStrings.appVersion}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.white50,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // WIDGET BUILDMENUITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDestructive = false,
    IconData? trailingIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: isDestructive
                        ? Colors.red.shade300
                        : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                trailingIcon ?? Icons.chevron_right,
                color: trailingIcon != null 
                    ? Colors.amber
                    : AppColors.white50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
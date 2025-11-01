import 'package:flutter/material.dart';
import 'package:projek_akhir_katolik/main.dart';
import 'package:projek_akhir_katolik/models/user_model.dart';
import 'package:projek_akhir_katolik/services/auth_service.dart';
import 'package:projek_akhir_katolik/screens/auth/login_screen.dart'; 

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Instance dari AuthService untuk mengecek status login.
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Memanggil fungsi untuk mengecek sesi pengguna yang sedang login
      future: _authService.getLoggedInUser(),
      
      builder: (context, snapshot) {
        // 1. KONEKSI MENUNGGU (LOADING)
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading spinner selagi mengecek sesi agar tidak ada flicker
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. SESI AKTIF (LOGGED IN)
        if (snapshot.hasData && snapshot.data != null) {
          // Jika data pengguna ditemukan, alihkan ke Navigation Wrapper utama
          return const MainNavigationWrapper();
        } 
        
        // 3. SESI TIDAK ADA (LOGGED OUT atau Gagal Memuat Data)
        else {
          // Jika sesi tidak ditemukan, alihkan ke Halaman Login
          return const LoginScreen();
        }
      },
    );
  }
}
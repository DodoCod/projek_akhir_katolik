import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir_katolik/services/auth_service.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';

/// Layar pendaftaran pengguna baru.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String _message = '';
  File? _selectedImage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Membuka galeri perangkat untuk memilih gambar profil.
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Gagal memilih gambar: ${e.toString()}';
      });
    }
  }

  /// Memproses pendaftaran pengguna baru.
  void _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Mohon isi username dan password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final success = await _authService.registerUser(
      _usernameController.text,
      _passwordController.text,
      _selectedImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Tampilkan pesan sukses dan kembali ke layar login setelah 2 detik
      setState(() {
        _message = 'Registrasi Berhasil! Silakan masuk.';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      // Tampilkan pesan error jika registrasi gagal
      setState(() {
        _message = 'Registrasi Gagal! Username mungkin sudah dipakai.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Judul
                  Text(
                    'Buat Akun Baru',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daftar untuk melanjutkan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.white20,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white50,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.white60,
                                ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.white20,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap untuk pilih foto (opsional)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Username Field
                    TextField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        'Username',
                        Icons.person_outline,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      decoration: _buildInputDecoration(
                        'Password',
                        Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    
                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Daftar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Login Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sudah punya akun? Masuk',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Message
                    if (_message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _message.contains('Gagal')
                              ? AppColors.red15
                              : AppColors.green15,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _message.contains('Gagal')
                                ? AppColors.red30
                                : AppColors.green30,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _message.contains('Gagal')
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _message,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// Helper untuk membangun dekorasi input field yang konsisten.
    InputDecoration _buildInputDecoration(
      String label,
      IconData icon, {
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white20,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      );
    }
  }
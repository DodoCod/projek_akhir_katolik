import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/services/auth_service.dart';
import 'package:projek_akhir_katolik/services/currency_service.dart';
import 'package:intl/intl.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';

class GoPremiumScreen extends StatefulWidget {
  const GoPremiumScreen({super.key});

  @override
  State<GoPremiumScreen> createState() => _GoPremiumScreenState();
}

class _GoPremiumScreenState extends State<GoPremiumScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final AuthService _authService = AuthService();
  
  // Future untuk mengambil Map kurs konversi {rateKey: rateValue}
  late Future<Map<String, dynamic>> _ratesFuture;
  
  // Harga basis dalam USD
  static const double _basePriceUSD = 10.0; 

  // State untuk mata uang yang dipilih pengguna
  String _selectedCurrency = 'IDR';
  final List<String> _targetCurrencies = ['IDR', 'EUR', 'JPY', 'MYR'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Memanggil API kurs saat inisialisasi state
    _ratesFuture = _currencyService.getConversionRates();
  }

  /// Memformat jumlah uang berdasarkan kode mata uang yang dipilih (misal: Rp 75.000,00).
  String _formatCurrency(double amount, String currencyCode) {
    String locale;
    String symbol;
    int decimalDigits = 0; // Default untuk IDR, JPY

    switch (currencyCode) {
      case 'IDR':
        locale = 'id_ID';
        symbol = 'Rp ';
        break;
      case 'EUR':
        locale = 'de_DE'; // Lokal untuk format Euro
        symbol = '€';
        decimalDigits = 2;
        break;
      case 'JPY':
        locale = 'ja_JP'; // Lokal Jepang
        symbol = '¥ ';
        break;
      case 'MYR':
        locale = 'ms_MY'; // Lokal Malaysia
        symbol = 'RM ';
        decimalDigits = 2;
        break;
      default:
        locale = 'en_US';
        symbol = '\$ '; 
        decimalDigits = 2;
    }

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Fungsi simulasi proses pembayaran dan upgrade ke status Premium.
  void _simulatePayment() async {
    setState(() { _isLoading = true; });

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pembayaran', style: GoogleFonts.poppins()),
        content: Text(
          'Ini hanya simulasi untuk tugas. Tidak ada biaya yang akan dikenakan. Lanjutkan "pembayaran"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lanjutkan')),
        ],
      )
    );

    if (confirm != true) {
      setState(() { _isLoading = false; });
      return;
    }

    // Simulasi penundaan pembayaran
    await Future.delayed(const Duration(seconds: 2));
    final success = await _authService.upgradeCurrentUserToPremium();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembayaran Berhasil! Akun Anda kini Premium.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke layar sebelumnya (ProfileScreen) dengan hasil TRUE
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal meng-upgrade akun.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Go Premium', style: GoogleFonts.poppins(color: Colors.white)),
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
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white15,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_open_rounded, color: Colors.amber, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Buka Fitur Premium',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  MembershipConfig.tierFeatures[MembershipTier.premium]!.join(', '),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Harga Asal USD
                Text(
                  'Harga Asal: \$${_basePriceUSD.toStringAsFixed(2)} (USD)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),

                // DROPDOWN MATA UANG
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    dropdownColor: AppColors.gradientEnd,
                    underline: const SizedBox(), 
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCurrency = newValue!;
                        // State diubah, FutureBuilder akan otomatis rebuild
                      });
                    },
                    items: _targetCurrencies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // TAMPILAN HARGA DARI FUTUREBUILDER
                FutureBuilder<Map<String, dynamic>>(
                  future: _ratesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: Colors.white);
                    }
                    if (snapshot.hasError) {
                      return Text('Gagal memuat harga (Cek API/Koneksi)', style: GoogleFonts.poppins(color: Colors.red));
                    }
                    if (snapshot.hasData) {
                      final rates = snapshot.data!;
                      final rateKey = 'USD$_selectedCurrency'; 

                      // Pastikan kurs tersedia dan bukan null
                      if (!rates.containsKey(rateKey) || rates[rateKey] == null) {
                        return Text(
                          'Kurs $_selectedCurrency tidak tersedia.',
                          style: GoogleFonts.poppins(color: Colors.red),
                        );
                      }
                      
                      final rate = rates[rateKey];
                      final convertedPrice = _basePriceUSD * rate;
                      final formattedPrice = _formatCurrency(convertedPrice, _selectedCurrency);

                      return Text(
                        formattedPrice, 
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                Text(
                  'Pembayaran sekali',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Bayar
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _simulatePayment,
                    child: Text(
                      'Bayar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
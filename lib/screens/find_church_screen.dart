import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_akhir_katolik/services/location_service.dart';
import 'package:projek_akhir_katolik/utils/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// Model sederhana untuk gereja yang sudah dihitung jaraknya
class ChurchLocation {
  final String name;
  final String address;
  final double distance; // dalam meter
  final double lat;
  final double lng;

  ChurchLocation({
    required this.name,
    required this.address,
    required this.distance,
    required this.lat,
    required this.lng,
  });
}

class FindChurchScreen extends StatefulWidget {
  const FindChurchScreen({super.key});

  @override
  State<FindChurchScreen> createState() => _FindChurchScreenState();
}

class _FindChurchScreenState extends State<FindChurchScreen> {
  bool _isLoading = false;
  String _message = 'Tekan tombol untuk mencari gereja terdekat...';
  List<ChurchLocation> _allChurches = []; // Daftar asli yang tidak diubah
  List<ChurchLocation> _filteredChurches = []; // Daftar yang ditampilkan di UI
  String _currentLocationDetail = ''; 
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // State untuk menyimpan query pencarian

  // FUNGSI GOOGLE MAPS
  Future<void> _launchMaps(double lat, double lng, String name) async {
    final mapUrl = Uri.parse('http://maps.google.com/maps?q=$lat,$lng($name)');
    
    if (!await launchUrl(mapUrl, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka Google Maps.')),
        );
      }
    }
  }

  // LOGIKA FILTERING PENCARIAN
  void _filterChurches(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChurches = _allChurches;
      } else {
        _filteredChurches = _allChurches.where((church) {
          // Filter berdasarkan nama atau alamat
          final nameMatches = church.name.toLowerCase().contains(lowerCaseQuery);
          final addressMatches = church.address.toLowerCase().contains(lowerCaseQuery);
          return nameMatches || addressMatches;
        }).toList();
      }
    });
  }
  
  Future<void> _findNearestChurches() async {
    setState(() {
      _isLoading = true;
      _message = 'Mendapatkan lokasi Anda...';
      _allChurches = [];
      _filteredChurches = [];
      _currentLocationDetail = ''; 
      _searchController.clear();
      _searchQuery = '';
    });

    try {
      final Position userPosition = await LocationService.getCurrentPosition();
      
      setState(() { _message = 'Menerjemahkan lokasi...'; });
      
      final String addressName = await LocationService.getAddressFromCoordinates(
        userPosition.latitude,
        userPosition.longitude,
      );
      
      _currentLocationDetail = addressName; 
      
      setState(() { _message = 'Menghitung jarak...'; });

      List<ChurchLocation> calculatedChurches = [];
      for (var churchData in DummyData.churches) {
        final double distance = LocationService.calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          churchData['lat'],
          churchData['lng'],
        );
        
        calculatedChurches.add(ChurchLocation(
          name: churchData['name'],
          address: churchData['address'],
          distance: distance,
          lat: churchData['lat'],
          lng: churchData['lng'],
        ));
      }

      calculatedChurches.sort((a, b) => a.distance.compareTo(b.distance));

      setState(() {
        _allChurches = calculatedChurches;
        _filteredChurches = calculatedChurches; 
        _isLoading = false;
        if (_allChurches.isEmpty) {
            _message = 'Tidak ada gereja ditemukan di area terdekat.';
        }
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _currentLocationDetail = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text('Pencari Gereja Terdekat', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget Informasi Lokasi Pengguna 
              if (_currentLocationDetail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, color: AppColors.purpleAccent, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lokasi Anda: $_currentLocationDetail',
                          style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Kolom Pencarian 
              if (_allChurches.isNotEmpty || _searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterChurches,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari nama gereja atau alamat...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.white50),
                      prefixIcon: Icon(Icons.search, color: AppColors.white70),
                      suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: Icon(Icons.clear, color: AppColors.white70),
                              onPressed: () {
                                _searchController.clear();
                                _filterChurches('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                  ),
                ),
              
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_allChurches.isEmpty && _searchQuery.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                )
              else if (_filteredChurches.isEmpty && _searchQuery.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Tidak ada hasil ditemukan untuk "$_searchQuery".',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredChurches.length, // Menggunakan daftar yang difilter
                    itemBuilder: (context, index) {
                      final church = _filteredChurches[index];
                      final distanceInKm = (church.distance / 1000).toStringAsFixed(1); 
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0), 
                        child: Card(
                          color: AppColors.white10, 
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.white20, width: 1), 
                          ),
                          child: ListTile(
                            onTap: () => _launchMaps(church.lat, church.lng, church.name), 
                            leading: Icon(Icons.church_rounded, color: AppColors.purpleAccent, size: 36), 
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              church.name,
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            subtitle: Text(
                              church.address,
                              style: GoogleFonts.poppins(color: AppColors.white70, fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$distanceInKm km',
                                  style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (_allChurches.isNotEmpty && _allChurches[0].name == church.name) 
                                  Text('Terdekat', style: GoogleFonts.poppins(color: AppColors.success, fontSize: 10)), 
                              ],
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16), 
        child: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _findNearestChurches,
          label: Text('Cari Sekarang', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          icon: Icon(Icons.location_on),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

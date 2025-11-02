import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_katolik/models/user_model.dart';
import 'package:projek_akhir_katolik/services/auth_service.dart';
import 'package:projek_akhir_katolik/screens/auth/auth_wrapper.dart';
import 'package:projek_akhir_katolik/screens/home_screen.dart';
import 'package:projek_akhir_katolik/screens/bible_screen.dart';
import 'package:projek_akhir_katolik/screens/prayer_screen.dart';
import 'package:projek_akhir_katolik/services/notification_service.dart';
import 'package:projek_akhir_katolik/screens/profile_screen.dart';
import 'package:projek_akhir_katolik/screens/find_church_screen.dart';
import 'package:projek_akhir_katolik/screens/world_time_screen.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Initialize Auth Service
  await AuthService.initialize();

  // Initialize Notification Service
  await NotificationService.initialize();
  
  log('✅ App initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rohani Katolik',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BibleScreen(),
    WorldTimeScreen(),
    FindChurchScreen(),
    PrayerScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Alkitab',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public_rounded),
              label: 'Waktu Dunia',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.church_rounded),
              label: 'Cari Gereja',
            ),
            BottomNavigationBarItem(
              icon: Icon(FlutterIslamicIcons.solidPrayer),
              label: 'Doa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF667eea),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
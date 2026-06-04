import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(const KStoreApp());
}

class KStoreApp extends StatefulWidget {
  const KStoreApp({Key? key}) : super(key: key);

  @override
  State<KStoreApp> createState() => _KStoreAppState();
}

class _KStoreAppState extends State<KStoreApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);

    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-STORE',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        fontFamily: 'Helvetica',
        scaffoldBackgroundColor: Colors.white,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        fontFamily: 'Helvetica',
      ),

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: LandingPage(),
    );
  }
}

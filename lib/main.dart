import 'package:flutter/material.dart';
import 'views/registro_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SenaiCheckInApp());
}

class SenaiCheckInApp extends StatelessWidget {
  const SenaiCheckInApp({super.key});

  static const Color _ouro = Color(0xFFD4AF37);
  static const Color _ouroClaro = Color(0xFFFFE082);
  static const Color _fundo = Color(0xFF0D0D11);
  static const Color _superficie = Color(0xFF181820);
  static const Color _card = Color(0xFF1F1F2A);
  static const Color _borda = Color(0x40D4AF37);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENAI CheckIn',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _fundo,
        colorScheme: const ColorScheme.dark(
          primary: _ouro,
          onPrimary: Colors.black,
          primaryContainer: Color(0xFF382F16),
          onPrimaryContainer: _ouroClaro,
          secondary: _ouroClaro,
          onSecondary: Colors.black,
          surface: _superficie,
          onSurface: Color(0xFFF2F2F5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _fundo,
          foregroundColor: _ouro,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: _ouro,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: _ouro),
        ),
        cardTheme: CardThemeData(
          color: _card,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _borda),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _ouro,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: StadiumBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _ouro,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _ouro,
            side: const BorderSide(color: _ouro),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _superficie,
          labelStyle: const TextStyle(color: Color(0xFFBDBDC7)),
          floatingLabelStyle: const TextStyle(color: _ouro),
          hintStyle: const TextStyle(color: Color(0xFF757585)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF383848))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF383848))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _ouro, width: 1.8)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF22222E),
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: _ouro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _borda),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const RegistroPage(),
    );
  }
}

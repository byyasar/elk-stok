import 'package:flutter/material.dart';
import 'package:flutter_application_temiz/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_temiz/screens/info_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_temiz/services/theme_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aswuxjtiufcgifmfqzyo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzd3V4anRpdWZjZ2lmbWZxenlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwMzg5MzAsImV4cCI6MjA3MzYxNDkzMH0.T9gXh7LEe06LISA6uHxidSCquRQi1fejpjSDEs4-kfw',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Elk STOK',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: const InfoScreen(), // Info sayfası ile başla
        );
      },
    );
  }
}
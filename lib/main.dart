import 'package:flutter/material.dart';
import 'package:flutter_application_temiz/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_temiz/screens/info_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_temiz/services/theme_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'your_supabase_url_here'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'your_supabase_anon_key_here'),
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
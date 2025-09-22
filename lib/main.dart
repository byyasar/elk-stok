import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_temiz/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_temiz/screens/info_screen.dart';
import 'package:flutter_application_temiz/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_temiz/services/theme_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Supabase bağlantısını test et
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Supabase credentials not found in environment variables');
  }
  
  print('***** Initializing Supabase with URL: $supabaseUrl');
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  print('***** Supabase init completed ${Supabase.instance}');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Supabase'den mevcut kullanıcıyı kontrol et
      final user = Supabase.instance.client.auth.currentUser;
      print('***** AuthWrapper - Current user: $user');
      
      setState(() {
        _isAuthenticated = user != null;
        _isLoading = false;
      });

      // Auth state değişikliklerini dinle
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        print('***** AuthWrapper - Auth state changed: ${data.event}');
        if (mounted) {
          setState(() {
            _isAuthenticated = data.session != null;
          });
        }
      });
    } catch (e) {
      print('***** AuthWrapper - Error checking auth state: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF137FEC),
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      // Kullanıcı giriş yapmışsa direkt ana sayfaya git
      print('***** AuthWrapper - User is authenticated, going to HomeScreen');
      return const HomeScreen();
    } else {
      // Kullanıcı giriş yapmamışsa info sayfasından başla
      print('***** AuthWrapper - User is not authenticated, going to InfoScreen');
      return const InfoScreen();
    }
  }
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
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // İngilizce
            Locale('tr', ''), // Türkçe
          ],
          locale: const Locale('tr', ''), // Varsayılan dil Türkçe
          home: const AuthWrapper(), // Auth durumuna göre yönlendir
        );
      },
    );
  }
}
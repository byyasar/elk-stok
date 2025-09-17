import 'package:flutter/material.dart';
import 'auth_screen.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  void initState() {
    super.initState();
    // 3 saniye sonra AuthScreen'e geç
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'lib/assets/images/info.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: Color(0xFF4FC3F7),
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Title
              const Text(
                'Stok Takip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Elektronik Stok Takip Uygulaması',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Features
              Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.inventory_2,
                    title: 'Ürün Yönetimi',
                    description: 'Elektronik ürünlerinizi kolayca ekleyin, düzenleyin ve silin',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    icon: Icons.analytics,
                    title: 'Stok Takibi',
                    description: 'Gerçek zamanlı stok durumunu takip edin',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    icon: Icons.photo_camera,
                    title: 'Resim Yükleme',
                    description: 'Ürün fotoğraflarını kamera veya galeriden yükleyin',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    icon: Icons.palette,
                    title: 'Tema Desteği',
                    description: 'Açık, koyu ve sistem teması arasında geçiş yapın',
                  ),
                ],
              ),
              
              const SizedBox(height: 64),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Yükleniyor...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4FC3F7),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


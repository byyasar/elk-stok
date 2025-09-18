import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_temiz/screens/info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Ayarlar',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSettingsSection(
                    context,
                    'Uygulama',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.notifications_outlined,
                        title: 'Bildirimler',
                        subtitle: 'Stok uyarıları ve güncellemeler',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.language_outlined,
                        title: 'Dil',
                        subtitle: 'Türkçe',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: 'Tema',
                        subtitle: 'Sistem teması',
                        onTap: () {
                          _showThemeSelectionDialog(context);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSettingsSection(
                    context,
                    'Veri',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.backup_outlined,
                        title: 'Yedekleme',
                        subtitle: 'Verileri yedekle ve geri yükle',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.download_outlined,
                        title: 'Dışa Aktar',
                        subtitle: 'Ürün listesini CSV olarak indir',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.delete_outline,
                        title: 'Verileri Temizle',
                        subtitle: 'Tüm ürünleri sil',
                        onTap: () => _showClearDataDialog(context),
                        isDestructive: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSettingsSection(
                    context,
                    'Hakkında',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.info_outline,
                        title: 'Uygulama Bilgisi',
                        subtitle: 'Sürüm 1.0.0',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.help_outline,
                        title: 'Yardım',
                        subtitle: 'SSS ve destek',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Gizlilik Politikası',
                        subtitle: 'Veri kullanımı ve gizlilik',
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSettingsSection(
                    context,
                    'Hesap',
                    [
                      _buildSettingsItem(
                        context,
                        icon: Icons.logout_outlined,
                        title: 'Çıkış Yap',
                        subtitle: 'Hesabınızdan çıkış yapın',
                        onTap: () => _showLogoutDialog(context),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyMedium?.color,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Çıkış Yap',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _logout(context);
              },
              child: Text(
                'Çıkış Yap',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // SharedPreferences'tan kaydedilen bilgileri temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      
      // Supabase'den çıkış yap
      await Supabase.instance.client.auth.signOut();
      
      if (context.mounted) {
        // Tüm sayfa geçmişini temizle ve InfoScreen'e git
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InfoScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Başarıyla çıkış yapıldı.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      print('Logout error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verileri Temizle',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            'Tüm ürün verileri kalıcı olarak silinecek. Bu işlem geri alınamaz.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement clear data functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bu özellik henüz aktif değil'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              },
              child: Text(
                'Temizle',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Tema Seçimi',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                'Koyu Tema',
                'Karanlık renk teması',
                Icons.dark_mode,
                () {
                  // TODO: Koyu tema uygula
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Koyu tema seçildi'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                'Açık Tema',
                'Aydınlık renk teması',
                Icons.light_mode,
                () {
                  // TODO: Açık tema uygula
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Açık tema seçildi'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOption(
                context,
                'Sistem Teması',
                'Sistem ayarlarını takip et',
                Icons.settings_suggest,
                () {
                  // TODO: Sistem teması uygula
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sistem teması seçildi'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
    );
  }
}
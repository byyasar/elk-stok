import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeSelectionDialog extends StatelessWidget {
  final ThemeService themeService;
  
  const ThemeSelectionDialog({
    super.key,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2127),
      title: const Text(
        'Tema Seçimi',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context,
            ThemeMode.dark,
            'Koyu Tema',
            'Karanlık renk teması',
            Icons.dark_mode,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            ThemeMode.light,
            'Açık Tema',
            'Aydınlık renk teması',
            Icons.light_mode,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            ThemeMode.system,
            'Sistem Teması',
            'Sistem ayarlarını takip et',
            Icons.settings_suggest,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'İptal',
            style: TextStyle(color: Color(0xFF9DABB9)),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode themeMode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = themeService.themeMode == themeMode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF137FEC) : const Color(0xFF9DABB9),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF137FEC) : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF9DABB9),
          fontSize: 12,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Color(0xFF137FEC),
              size: 20,
            )
          : null,
      onTap: () {
        themeService.setTheme(themeMode);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? const Color(0xFF137FEC) : Colors.transparent,
          width: 1,
        ),
      ),
    );
  }
}

# Elk STOK - Elektronik Stok Takip Uygulaması

Modern ve kullanıcı dostu bir stok takip uygulaması. Flutter ve Supabase teknolojileri kullanılarak geliştirilmiştir.

## 🚀 Özellikler

- **Ürün Yönetimi**: Ürün ekleme, düzenleme, silme ve listeleme
- **Stok Takibi**: Renk kodlu stok göstergeleri (yeşil: stok var, kırmızı: stok yok)
- **Resim Yükleme**: Supabase Storage ile resim yükleme ve görüntüleme
- **Arama**: Ürün arama ve filtreleme
- **Tema Sistemi**: Açık, koyu ve sistem teması desteği
- **Kullanıcı Kimlik Doğrulama**: Güvenli giriş ve kayıt sistemi
- **Hatırlama**: Email ve şifre hatırlama özelliği
- **Responsive Tasarım**: iOS ve Android desteği

## 🛠️ Teknolojiler

- **Flutter**: Cross-platform mobil uygulama geliştirme
- **Supabase**: Backend as a Service (Baas)
- **Supabase Auth**: Kullanıcı kimlik doğrulama
- **Supabase Storage**: Dosya depolama
- **Provider**: State management
- **Shared Preferences**: Yerel veri saklama
- **Image Picker**: Kamera ve galeri erişimi
- **Cached Network Image**: Resim önbellekleme

## 📱 Ekran Görüntüleri

### Ana Özellikler
- Info sayfası (3 saniye otomatik geçiş)
- Giriş/Kayıt sayfası
- Ana sayfa (ürün listesi)
- Ürün ekleme/düzenleme sayfası
- Ürün detay sayfası
- Ayarlar sayfası

### Tema Desteği
- Açık tema
- Koyu tema
- Sistem teması (otomatik)

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- iOS Simulator veya Android Emulator
- Supabase hesabı

### Adımlar

1. **Repository'yi klonlayın**
   ```bash
   git clone https://github.com/kullaniciadi/elk-stok.git
   cd elk-stok
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Supabase yapılandırması**
   - Supabase projesi oluşturun
   - `env.example` dosyasını `env` olarak kopyalayın
   - `env` dosyasında Supabase URL ve anon key'inizi güncelleyin
   - Supabase'de `products` tablosunu oluşturun
   - Storage bucket'ı oluşturun
   - Uygulamayı çalıştırırken environment variables'ları belirtin:
     ```bash
     flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 🗄️ Veritabanı Yapısı

### Products Tablosu
```sql
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2),
  stock INTEGER DEFAULT 0,
  location TEXT,
  image_url TEXT,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### RLS (Row Level Security) Politikaları
- Kullanıcılar sadece kendi ürünlerini görebilir
- Kullanıcılar sadece kendi ürünlerini ekleyebilir/düzenleyebilir/silebilir

## 📦 Supabase Storage

- **Bucket**: `product_images`
- **Dosya Formatı**: PNG, JPG, JPEG
- **Maksimum Boyut**: 10MB
- **Erişim**: Public URL'ler

## 🎨 Tema Sistemi

Uygulama Material 3 tasarım sistemini kullanır ve üç farklı tema modunu destekler:

- **Açık Tema**: Gün ışığında kullanım için
- **Koyu Tema**: Düşük ışıkta kullanım için
- **Sistem Teması**: Cihaz ayarlarını takip eder

## 🔧 Geliştirme

### Proje Yapısı
```
lib/
├── data/           # Veri katmanı
├── models/         # Veri modelleri
├── screens/        # Ekranlar
├── widgets/        # Yeniden kullanılabilir widget'lar
├── services/       # Servisler
├── theme/          # Tema dosyaları
└── main.dart       # Ana dosya
```

### Önemli Dosyalar
- `lib/main.dart`: Uygulama giriş noktası
- `lib/data/product_service.dart`: Supabase CRUD işlemleri
- `lib/theme/app_theme.dart`: Tema tanımları
- `lib/services/theme_service.dart`: Tema yönetimi

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📞 İletişim

- Proje Sahibi: [GitHub Kullanıcı Adı]
- Email: [email@example.com]

## 🙏 Teşekkürler

- Flutter ekibine
- Supabase ekibine
- Açık kaynak topluluğuna
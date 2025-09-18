import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import '../models/product.dart';

class OutputScreen extends StatefulWidget {
  final List<Product> products;
  final String filterType;
  final String searchQuery;

  const OutputScreen({
    super.key,
    required this.products,
    required this.filterType,
    required this.searchQuery,
  });

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  bool _isGeneratingPdf = false;
  bool _includeImages = true; // Resimleri dahil etme ayarı

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çıktı - ${widget.products.length} Ürün',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Oluştur ve Paylaş',
          ),
          IconButton(
            onPressed: _printProducts,
            icon: const Icon(Icons.print),
            tooltip: 'Yazdır',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre Bilgileri
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtre Bilgileri',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtre: ${widget.filterType}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (widget.searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Arama: "${widget.searchQuery}"',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Toplam: ${widget.products.length} ürün',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resim Ayarı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resimleri Dahil Et',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'PDF\'de ürün resimlerini göster',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _includeImages,
                  onChanged: (value) {
                    setState(() {
                      _includeImages = value;
                    });
                  },
                  activeColor: const Color(0xFF137FEC),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ürün Listesi
          Expanded(
            child: widget.products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gösterilecek ürün bulunamadı',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return _buildProductCard(context, product, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sıra Numarası
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF137FEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$index',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF137FEC),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Ürün Resmi (eğer resimler dahil edilecekse)
          if (_includeImages)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).dividerColor,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(width: 16),

          // Ürün Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.description.isNotEmpty) ...[
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Stok: ${product.stock}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: product.stock > 0 ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (product.location.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Konum: ${product.location}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdf = await _generatePdf();
      
      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Elk_STOK_Urun_Listesi_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    // Resimleri önceden yükle
    Map<String, Uint8List> imageCache = {};
    if (_includeImages) {
      for (final product in widget.products) {
        if (product.imageUrl.isNotEmpty && product.imageUrl.startsWith('http')) {
          try {
            final imageBytes = await _loadImageBytes(product.imageUrl);
            imageCache[product.imageUrl] = imageBytes;
          } catch (e) {
            print('Failed to load image for ${product.name}: $e');
          }
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Başlık
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Elk STOK - Ürün Listesi',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Tarih: ${_formatDate(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Filtre Bilgileri
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Filtre Bilgileri',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Filtre: ${widget.filterType}'),
                  if (widget.searchQuery.isNotEmpty)
                    pw.Text('Arama: "${widget.searchQuery}"'),
                  pw.Text('Toplam: ${widget.products.length} ürün'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Ürün Listesi
            ...widget.products.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final product = entry.value;
              
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    // Sıra Numarası
                    pw.Container(
                      width: 30,
                      height: 30,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(15),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '$index',
                          style: pw.TextStyle(
                            color: PdfColors.blue800,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),

                    // Ürün Bilgileri
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            product.name,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (product.description.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              product.description,
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                          pw.SizedBox(height: 4),
                          pw.Row(
                            children: [
                              pw.Text(
                                'Stok: ${product.stock}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: product.stock > 0 ? PdfColors.green : PdfColors.red,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              if (product.location.isNotEmpty) ...[
                                pw.SizedBox(width: 16),
                                pw.Text(
                                  'Konum: ${product.location}',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Ürün Resmi (eğer resimler dahil edilecekse)
                    if (_includeImages && product.imageUrl.isNotEmpty && product.imageUrl.startsWith('http')) ...[
                      pw.SizedBox(width: 16),
                      pw.Container(
                        width: 60,
                        height: 60,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: imageCache.containsKey(product.imageUrl)
                            ? pw.Image(
                                pw.MemoryImage(imageCache[product.imageUrl]!),
                                fit: pw.BoxFit.cover,
                              )
                            : pw.Center(
                                child: pw.Text(
                                  'Resim\nYüklenemedi',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<void> _printProducts() async {
    try {
      final pdf = await _generatePdf();
      
      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Elk_STOK_Urun_Listesi',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yazdırma sırasında hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<Uint8List> _loadImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception('Failed to load image: ${response.statusCode}');
    } catch (e) {
      print('Error loading image: $e');
      rethrow;
    }
  }
}

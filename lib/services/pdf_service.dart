import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';

class PdfService {
  static Future<void> generateAndPrintProductList(List<Product> products) async {
    try {
      // Check if products list is empty
      if (products.isEmpty) {
        throw Exception('Yazdırılacak ürün bulunamadı');
      }
      
      final pdf = await _generateProductListPdf(products);
      
      // Show PDF preview with save/share options
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await pdf.save(),
        name: 'Ürün Listesi - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );
    } catch (e) {
      throw Exception('PDF oluşturulurken hata oluştu: $e');
    }
  }

  static Future<void> generateAndShareProductList(List<Product> products) async {
    try {
      // Check if products list is empty
      if (products.isEmpty) {
        throw Exception('Paylaşılacak ürün bulunamadı');
      }
      
      final pdf = await _generateProductListPdf(products);
      
      // Save PDF to temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'urun_listesi_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(await pdf.save());
      
      // Share the PDF file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ELK STOK - Ürün Listesi',
        subject: 'Ürün Listesi - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      );
    } catch (e) {
      throw Exception('PDF paylaşılırken hata oluştu: $e');
    }
  }

  static Future<String> generateAndSaveProductList(List<Product> products) async {
    try {
      final pdf = await _generateProductListPdf(products);
      
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'urun_listesi_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(await pdf.save());
      
      // Return the file path for user information
      return file.path;
    } catch (e) {
      throw Exception('PDF kaydedilirken hata oluştu: $e');
    }
  }

  static Future<pw.Document> _generateProductListPdf(List<Product> products) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'ELK STOK - Ürün Listesi',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                  pw.Text(
                    'Tarih: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'Toplam Ürün',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        '${products.length}',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Toplam Stok',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        '${products.fold(0, (sum, product) => sum + product.stock)}',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Products table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2), // Name
                1: const pw.FlexColumnWidth(1), // Stock
                2: const pw.FlexColumnWidth(1), // Price
                3: const pw.FlexColumnWidth(2), // Location
                4: const pw.FlexColumnWidth(1), // Date
                5: const pw.FlexColumnWidth(3), // Description
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                  children: [
                    _buildTableCell('Ürün Adı', isHeader: true),
                    _buildTableCell('Stok', isHeader: true),
                    _buildTableCell('Fiyat', isHeader: true),
                    _buildTableCell('Konum', isHeader: true),
                    _buildTableCell('Tarih', isHeader: true),
                    _buildTableCell('Açıklama', isHeader: true),
                  ],
                ),
                // Data rows
                ...products.map((product) => pw.TableRow(
                  children: [
                    _buildTableCell(product.name),
                    _buildTableCell('${product.stock}'),
                    _buildTableCell(product.price != null ? '₺${product.price!.toStringAsFixed(2)}' : '-'),
                    _buildTableCell(product.location.isNotEmpty ? product.location : '-'),
                    _buildTableCell(product.createdAt != null 
                        ? '${product.createdAt!.day}.${product.createdAt!.month}.${product.createdAt!.year}' 
                        : '-'),
                    _buildTableCell(product.description.isNotEmpty ? product.description : '-'),
                  ],
                )).toList(),
              ],
            ),
            
            // Footer
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Bu rapor ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} tarihinde oluşturulmuştur.',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue800 : PdfColors.black,
        ),
        textAlign: pw.TextAlign.left,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

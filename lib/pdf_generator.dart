import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:swipe/nwipe_services.dart';

class PdfGenerator {
  final SwipeProvider swipeProvider;

  PdfGenerator(this.swipeProvider);

  Future<void> generateAndShowReport(BuildContext context) async {
    pw.Document? pdf;

    try {
      // Generate the PDF
      pdf = await _generatePdf();

      // Show PDF preview with save option
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf!.save(),
        name:
            'Disk Erasure Report - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
      );

      // Check if context is still valid before showing dialog
      if (!context.mounted) return;

      // Ask user if they want to save the PDF
      final shouldSave =
          await showDialog<bool>(
            context: context,
            builder:
                (dialogContext) => AlertDialog(
                  title: const Text('Save Report'),
                  content: const Text(
                    'Do you want to save this report as a PDF file?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
          ) ??
          false;

      // Check if context is still valid before saving
      if (!context.mounted) return;

      if (shouldSave) {
        await _savePdf(pdf);
      }
    } catch (e) {
      // Handle any errors during PDF generation
      debugPrint('Error generating PDF report: $e');

      // Check if context is still valid before showing snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF report: $e')),
        );
      }
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    // Create a simple barcode pattern as a memory image
    final barcodeImage = await _generateBarcodeImage();

    // Add pages to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with barcode
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(barcodeImage, width: 200, height: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Model: ${swipeProvider.includedDrives.isNotEmpty ? swipeProvider.includedDrives[0].name : "N/A"}',
                      ),
                      pw.Text('S/N: XXXXXXXXXXXXX'),
                    ],
                  ),
                ],
              ),

              // Title
              pw.Center(
                child: pw.Text(
                  'Disk Erasure Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(child: pw.Text('Page 1 - Erasure Status')),

              pw.Divider(),

              // Organization section
              pw.Text(
                'Organisation Performing The Disk Erasure',
                style: pw.TextStyle(
                  color: PdfColors.blue,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Business Name:'),
                      pw.Text('Business Address:'),
                      pw.Text('Contact Name:'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('EraseTheDisk.Com'),
                      pw.Text('Platter Drive'),
                      pw.Text('The Eraser'),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Text('Contact Phone:'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Text('+01 662 7726 8882983'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Customer section
              pw.Text(
                'Customer Details',
                style: pw.TextStyle(
                  color: PdfColors.blue,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name:'),
                      pw.Text('Address:'),
                      pw.Text('Contact Name:'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ServerCity.com'),
                      pw.Text('Somewhere Street'),
                      pw.Text('Admin Jo'),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Text('Contact Phone:'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Text('+44 0897665 877656'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Disk Information
              pw.Text(
                'Disk Information',
                style: pw.TextStyle(
                  color: PdfColors.blue,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              if (swipeProvider.includedDrives.isNotEmpty) ...[
                pw.Row(
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Make/Model:'),
                        pw.Text('Size(Apparent):'),
                        pw.Text('Size(Physical):'),
                      ],
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(swipeProvider.includedDrives[0].name),
                        pw.Text(
                          '${swipeProvider.includedDrives[0].size}, 500107862016 bytes',
                        ),
                        pw.Text(
                          '${swipeProvider.includedDrives[0].size}, 500107862016 bytes',
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [pw.Text('Serial:'), pw.Text('Bus:')],
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [pw.Text('XXXXXXXXXXXX'), pw.Text('ATA')],
                    ),
                  ],
                ),
              ] else ...[
                pw.Container(child: pw.Text('No drives selected for erasure')),
              ],

              pw.SizedBox(height: 10),

              // Disk Erasure Details
              pw.Text(
                'Disk Erasure Details',
                style: pw.TextStyle(
                  color: PdfColors.blue,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Start time:'),
                      pw.Text('Duration:'),
                      pw.Text('Method:'),
                      pw.Text('Final Pass(Zeros/Ones/None):'),
                      pw.Text('*Bytes Erased:'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        dateFormat.format(
                          now.subtract(const Duration(hours: 1)),
                        ),
                      ),
                      pw.Text('06:27:24'),
                      pw.Text(swipeProvider.eraseMethod),
                      pw.Text('Zeros'),
                      pw.Text('500107862016, (100.00%)'),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('End time:'),
                      pw.Text('Status:'),
                      pw.Text('PRNG algorithm:'),
                      pw.Text('Verify Pass(Last/All/None):'),
                      pw.Text('Rounds(completed/requested):'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(dateFormat.format(now)),
                      pw.Text(
                        'ERASED',
                        style: pw.TextStyle(color: PdfColors.green),
                      ),
                      pw.Text(
                        swipeProvider.prngMethod.isEmpty
                            ? 'isaac'
                            : swipeProvider.prngMethod,
                      ),
                      pw.Text(
                        swipeProvider.verifyEnabled ? 'Verify All' : 'None',
                      ),
                      pw.Text('1/1'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HPA/DCO:'),
                      pw.Text('Errors(pass/sync/verify):'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [pw.Text('No hidden sectors'), pw.Text('0/0/0')],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HPA/DCO Size:'),
                      pw.Text('Throughput:'),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('No hidden sectors'),
                      pw.Text('86 MB/sec'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Text(
                '* bytes erased: The amount of drive that\'s been erased at least once',
                style: pw.TextStyle(fontSize: 10),
              ),

              pw.SizedBox(height: 10),

              // Technician section
              pw.Text(
                'Technician/Operator ID',
                style: pw.TextStyle(
                  color: PdfColors.blue,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [pw.Text('Name/ID:')],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [pw.Text('The Master Eraser')],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [pw.Text('Signature:')],
                  ),
                  pw.SizedBox(width: 20),
                  pw.SizedBox(width: 150),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text('Disk Erasure by NWIPE version 0.35')),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _savePdf(pw.Document pdf) async {
    try {
      // Ask user for save location
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Disk Erasure Report',
        fileName:
            'Disk_Erasure_Report_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf',
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        // Save the PDF
        final file = File(outputFile);
        await file.writeAsBytes(await pdf.save());
      }
    } catch (e) {
      debugPrint('Error saving PDF: $e');
    }
  }

  Future<pw.MemoryImage> _generateBarcodeImage() async {
    // Create a simple barcode pattern as a memory image
    final width = 300;
    final height = 100;
    final bytesPerPixel = 4; // RGBA

    final Uint8List pixels = Uint8List(width * height * bytesPerPixel);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = (y * width + x) * bytesPerPixel;

        // Create a barcode pattern
        final bool isBar = (x ~/ 4) % 3 == 0;

        // RGBA values
        pixels[index] = isBar ? 0 : 255; // R
        pixels[index + 1] = isBar ? 0 : 255; // G
        pixels[index + 2] = isBar ? 0 : 255; // B
        pixels[index + 3] = 255; // A (opacity)
      }
    }

    return pw.MemoryImage(pixels);
  }
}

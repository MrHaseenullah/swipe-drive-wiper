import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:swipe/nwipe_services.dart';
import 'package:swipe/pdf_generator.dart';

class PdfReportButton extends StatelessWidget {
  const PdfReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SwipeProvider>(
      builder: (context, swipeProvider, child) {
        // Show the button when wipe is completed
        if (!swipeProvider.wipeCompleted) {
          return const SizedBox.shrink(); // Don't show if wipe not completed
        }

        // Debug log to verify the button should be showing
        debugPrint(
          'PDF Report Button should be visible - wipeCompleted: ${swipeProvider.wipeCompleted}',
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Wipe operation completed successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  // Generate and show PDF report
                  final pdfGenerator = PdfGenerator(swipeProvider);
                  await pdfGenerator.generateAndShowReport(context);

                  // Reset the wipeCompleted flag after showing the report
                  // This is optional - you might want to keep it true until a new wipe starts
                  // swipeProvider.resetWipeCompleted();
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a PDF report of the wipe operation for your records',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

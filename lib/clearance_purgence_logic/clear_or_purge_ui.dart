import 'package:flutter/material.dart';
import 'package:swipe/nwipe_services.dart';

class ClearOrPurgeUi extends StatelessWidget {
  final SwipeProvider swipeProvider;

  const ClearOrPurgeUi(this.swipeProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    // This widget should only be shown on Linux
    // The check is also in nwipe_ui_screen.dart, but we add it here as a safeguard
    if (!swipeProvider.isLinux) {
      return const SizedBox.shrink(); // Return empty widget for Windows
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drive Wiping Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Use Nwipe'),
                    value: true,
                    groupValue: swipeProvider.shouldNwipeOrHdParm,
                    onChanged: (value) {
                      if (value != null) swipeProvider.setNwipeForDrives(value);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Use Secure Erase'),
                    value: false,
                    groupValue: swipeProvider.shouldNwipeOrHdParm,
                    onChanged: (value) {
                      if (value != null) swipeProvider.setNwipeForDrives(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

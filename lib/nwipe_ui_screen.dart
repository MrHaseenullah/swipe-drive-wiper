import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:swipe/beta_features_screen.dart';
import 'package:swipe/main.dart';
import 'package:swipe/nwipe_services.dart';
import 'package:swipe/rich_documentation.dart';
import 'package:swipe/pdf_report_button.dart';

class MainUIScreen extends StatefulWidget {
  const MainUIScreen({super.key});

  @override
  State<MainUIScreen> createState() => _MainUIScreenState();
}

class _MainUIScreenState extends State<MainUIScreen> {
  bool isRunning = false;
  bool showNwipeUI = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => swipeProvider,
      builder: (context, child) {
        return Consumer<SwipeProvider>(
          builder: (context, swipeProvider, child) {
            return Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width * 0.05,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      //main ui
                      Center(
                        child: ElevatedButton.icon(
                          //primary background color
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          icon: Icon(Icons.refresh),
                          onPressed: () async {
                            if (isRunning) {
                              return;
                            }
                            isRunning = true;
                            //call the detect drives function
                            await swipeProvider.detectDrives();
                            isRunning = false;
                          },
                          label: Text('Detect Drives'),
                          //slide down then shake animation on the button using flutter animate
                        ).animate(
                          //rebuild on hot reload
                          effects: [
                            SlideEffect(
                              begin: Offset(0, -1),
                              end: Offset(0, 0),
                              duration: Duration(milliseconds: 500),
                            ),
                            ShakeEffect(
                              delay: Duration(milliseconds: 500),
                              hz: 2,
                              duration: Duration(milliseconds: 500),
                            ),
                          ],
                        ),
                      ),

                      globalVerticalSpace(),
                      //wrap widget to display the drives
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Drives Detected: ${swipeProvider.allDrives.length}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Wrap(
                        children: [
                          //heading for detecting drives

                          //display the drives
                          ...swipeProvider.allDrives.map((drive) {
                            bool isIncluded = swipeProvider.includedDrives
                                .contains(drive);
                            return Card(
                              child: InkWell(
                                //make the splash radius match the card
                                borderRadius: BorderRadius.circular(10),
                                // Disable tap for system drives
                                onTap:
                                    drive.isSystemDrive
                                        ? null
                                        : () {
                                          swipeProvider.changeInclusion(
                                            drive.index,
                                          );
                                          log(
                                            'Drive: ${drive.name}, Size: ${drive.size} is included: $isIncluded',
                                          );
                                        },
                                child: AnimatedContainer(
                                  padding: EdgeInsets.all(10),

                                  margin:
                                      (isIncluded)
                                          ? EdgeInsets.all(10)
                                          : EdgeInsets.all(11.5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        drive.isSystemDrive
                                            ? Colors.red.withAlpha(30)
                                            : isIncluded
                                            ? Theme.of(context).primaryColor
                                            : Colors.white,
                                    border: Border.all(
                                      width: (isIncluded) ? 5 : 2,
                                      //draw stroke inwards
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                      color:
                                          drive.isSystemDrive
                                              ? Colors.red
                                              : isIncluded
                                              ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimary
                                              : Theme.of(
                                                context,
                                              ).colorScheme.secondaryContainer,
                                    ),
                                  ),
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  child: Stack(
                                    children: [
                                      //create a check icon at the top left corner
                                      if (isIncluded)
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Icon(
                                            Icons.check_circle,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                          ),
                                        ),

                                      // Warning icon for system drives
                                      if (drive.isSystemDrive)
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                        ),

                                      Container(
                                        margin: EdgeInsets.all(5),
                                        padding:
                                            //add more symetric horizontal padding if included
                                            (isIncluded)
                                                ? EdgeInsets.symmetric(
                                                  horizontal: 40,
                                                  vertical: 10,
                                                )
                                                : EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Drive: ${drive.name}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    isIncluded
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.onPrimary
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // Location line removed
                                            Text(
                                              'Size: ${drive.size}',
                                              style: TextStyle(
                                                color:
                                                    isIncluded
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.onPrimary
                                                        : Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            // Warning text for system drives
                                            if (drive.isSystemDrive)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.red,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'SYSTEM DRIVE - CANNOT BE WIPED',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),

                      globalVerticalSpace(),

                      // Only show wipe options on Linux
                      if (swipeProvider.isLinux) ClearOrPurgeUi(swipeProvider),

                      // Only show Linux-specific wiping options on Linux
                      if (swipeProvider.isLinux &&
                          swipeProvider.shouldNwipeOrHdParm)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //alright now lets work on the radio buttons for adding the wipe options
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  showDocumentationADB('eraseMethod', context);
                                },
                                child: Text(
                                  'Wipe Options',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ).animate().slideY(
                              //slide up
                              begin: 0.2,
                              end: 0,
                              duration: 500.ms,
                            ),

                            Wrap(
                              children: [
                                ...eraseMethods.map((option) {
                                  return Row(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Radio(
                                              value: option,
                                              groupValue:
                                                  swipeProvider.eraseMethod,
                                              onChanged: (value) {
                                                swipeProvider.changeEraseMethod(
                                                  value.toString(),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(option),

                                      //info icon to display the in
                                      IconButton(
                                        icon: Icon(
                                          Icons.description_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          log('Show documentation for $option');
                                          if (globalInfoMap.containsKey(
                                            option,
                                          )) {
                                            showDocumentationADB(
                                              option,
                                              context,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ).animate().slideY(
                              //slide up
                              begin: 0.2,
                              end: 0,
                              duration: 500.ms,
                            ),

                            //we will show the prng methods only if the user selects the
                            // eraseMethods[4] which is the PRNG method, and only on Linux
                            if (swipeProvider.isLinux &&
                                swipeProvider.eraseMethod == eraseMethods[4])
                              Column(
                                children: [
                                  globalVerticalSpace(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'PRNG Methods',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      ...prngMethods.map((option) {
                                        return Row(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Radio(
                                                    value: option,
                                                    groupValue:
                                                        swipeProvider
                                                            .prngMethod,
                                                    onChanged: (value) {
                                                      swipeProvider.changePRNG(
                                                        value.toString(),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(option),
                                            //info icon to display the in
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ],
                              ),

                            // Only show these options on Linux
                            if (swipeProvider.isLinux) ...[
                              globalVerticalSpace(),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  NumberOfRoundsWidget(),
                                  VerificationToggleWidget(),
                                  BlankingToggleWidget(),
                                ],
                              ).animate().slideY(
                                //slide up
                                begin: 0.2,
                                end: 0,
                                duration: 500.ms,
                              ),
                            ],

                            //switch for blanking at the end
                            globalVerticalSpace(),
                            const SizedBox(height: 50),

                            // Only show Run Nwipe button on Linux
                            if (swipeProvider.isLinux)
                              Column(
                                children: [
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        //get the executable string
                                        String command =
                                            swipeProvider.setExecutableString();
                                        log(command);
                                        await swipeProvider.eraseDrive(
                                          command,
                                          swipeProvider.sudoPassword,
                                        );
                                        log('Ran Nwipe and is done');
                                      },
                                      icon: Icon(Icons.play_arrow),
                                      label: Text('Run Nwipe'),
                                    ),
                                  ),

                                  // PDF Report Button for Linux
                                  const PdfReportButton(),
                                ],
                              ),

                            // Windows-specific message is now moved below the drives section

                            //show the executable string
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     'Executable String',
                            //     style: TextStyle(
                            //       fontSize: 20,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),

                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: SelectableText(
                            //     swipeProvider.executableString,
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 20),

                            // System Log Section - Always visible on both platforms
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 100.0,
                                      bottom: 8.0,
                                    ),
                                    child: Text(
                                      'System Log',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 100,
                                      ),
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SingleChildScrollView(
                                        reverse: true,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SelectableText(
                                              swipeProvider
                                                      .systemLogText
                                                      .isEmpty
                                                  ? 'No system logs available yet.'
                                                  : swipeProvider.systemLogText,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Only show wipe logs on Linux
                            if (swipeProvider.isLinux) ...[
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 100.0,
                                  bottom: 8.0,
                                ),
                                child: Text(
                                  'Wipe Operation Log',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              //here is the container for the wipe logs
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 100,
                                  ),
                                  height: 230,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SingleChildScrollView(
                                    //MAKE SURE THAT WE ARE ALWAYS AT THE END
                                    reverse: true,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Text(logInfo,), MAKE IT SELECTABLE
                                        SelectableText(
                                          swipeProvider.wipeLogText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                      if (!swipeProvider.shouldNwipeOrHdParm)
                        Column(
                          children: [
                            //!Here is the ui for hdParm
                            //  if no drives are selected then show the message
                            if (swipeProvider.includedDrives.isEmpty ||
                                swipeProvider.includedDrives.length > 1)
                              Text(
                                'Please select a single drive to purge',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (swipeProvider.includedDrives.length == 1)
                              ShowHDParmUI(),
                          ],
                        ),

                      // Windows Wiping Options Section - Displayed prominently below drives
                      if (swipeProvider.isWindows)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Windows Wiping Options',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select Wiping Method:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: const Text(
                                              'SDelete (Microsoft)',
                                            ),
                                            subtitle: const Text(
                                              'Fast, command-line based',
                                            ),
                                            value: 'sdelete',
                                            groupValue:
                                                swipeProvider.windowsWipeMethod,
                                            onChanged: (value) {
                                              if (value != null) {
                                                swipeProvider
                                                    .setWindowsWipeMethod(
                                                      value,
                                                    );
                                              }
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: const Text('Eraser'),
                                            subtitle: const Text(
                                              'More options, GUI-based',
                                            ),
                                            value: 'eraser',
                                            groupValue:
                                                swipeProvider.windowsWipeMethod,
                                            onChanged: (value) {
                                              if (value != null) {
                                                swipeProvider
                                                    .setWindowsWipeMethod(
                                                      value,
                                                    );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      children: [
                                        Center(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              // Get selected drives
                                              if (swipeProvider
                                                  .includedDrives
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Please select at least one drive to wipe',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              // Run the selected wiping method on Windows
                                              await swipeProvider.eraseDrive(
                                                '', // No command needed for Windows as it's handled internally
                                                swipeProvider.sudoPassword,
                                              );
                                              log(
                                                'Ran ${swipeProvider.windowsWipeMethod} and is done',
                                              );
                                            },
                                            icon: Icon(Icons.delete_forever),
                                            label: Text(
                                              'Securely Erase Selected Drives',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade700,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 16,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // PDF Report Button for Windows
                                        const SizedBox(height: 16),
                                        const PdfReportButton(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      // System Logs Display for Windows
                      if (swipeProvider.isWindows)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Logs',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade50,
                                ),
                                child: SingleChildScrollView(
                                  reverse: true,
                                  child: SelectableText(
                                    swipeProvider.systemLogText.isEmpty
                                        ? 'No logs available yet. Start the wiping process to see logs.'
                                        : swipeProvider.systemLogText,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            //  Navigate using material route to BetaFeaturesScreen

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BetaFeaturesScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.flag_circle_rounded),
                          label: Text('Beta Features'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ShowPurgeButton extends StatelessWidget {
  const ShowPurgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () async {
            log('Purge button pressed');
            await swipeProvider.startPurge(swipeProvider.includedDrives[0]);
          },
          icon: Icon(Icons.security),
          label: Text('Purge Drives'),
        ),
      ),
    );
  }
}

class ShowHDParmUI extends StatelessWidget {
  const ShowHDParmUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              // Compatibility Status
              if (swipeProvider.includedDrives.isNotEmpty)
                _buildCompatibilityStatus(),

              if (swipeProvider.includedDrives[0].isHDParmCompatable)
                Column(
                  children: [
                    ShowPurgeButton(),

                    // PDF Report Button for HDParm
                    const PdfReportButton(),
                  ],
                ),

              // Logs Container
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 100),
                height: 230,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SingleChildScrollView(
                  reverse: true,
                  child: LogViewer(), // Create separate widget for logs
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityStatus() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color:
            swipeProvider.includedDrives[0].isHDParmCompatable
                ? Colors.green.withAlpha(25)
                : Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            swipeProvider.includedDrives[0].isHDParmCompatable
                ? Icons.check_circle
                : Icons.warning,
            color:
                swipeProvider.includedDrives[0].isHDParmCompatable
                    ? Colors.green
                    : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            swipeProvider.includedDrives[0].isHDParmCompatable
                ? 'Drive is compatible with hdparm'
                : 'Drive may not be fully compatible with hdparm',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Separate widget for logs
class LogViewer extends StatelessWidget {
  const LogViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SwipeProvider>(
      builder: (context, provider, _) {
        try {
          // Show both system logs and specific logs
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.systemLogText.isNotEmpty) ...[
                const Text(
                  'System Logs:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  provider.systemLogText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              if (provider.logText.isNotEmpty) ...[
                const Text(
                  'Operation Logs:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  provider.logText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ],
              if (provider.systemLogText.isEmpty && provider.logText.isEmpty)
                const Text(
                  'No logs available yet.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
            ],
          );
        } catch (e) {
          return const Text(
            'Error displaying logs. Please check encoding.',
            style: TextStyle(color: Colors.red),
          );
        }
      },
    );
  }
}

class BlankingToggleWidget extends StatelessWidget {
  const BlankingToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () {
              showDocumentationADB('blankingOption', context);
            },
            child: Text(
              'Blank at the end',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 40),
        Switch(
          value: swipeProvider.blankEnabled,
          onChanged: (value) {
            swipeProvider.enableBlank(value);
          },
        ),
      ],
    );
  }
}

class VerificationToggleWidget extends StatelessWidget {
  const VerificationToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () {
              showDocumentationADB('verificationOptions', context);
            },
            child: Text(
              'Verify Wipe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 40),
        Switch(
          value: swipeProvider.verifyEnabled,
          onChanged: (value) {
            swipeProvider.enableVerify(value);
          },
        ),
      ],
    );
  }
}

class NumberOfRoundsWidget extends StatelessWidget {
  const NumberOfRoundsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () {
              //numberOfWipeRounds

              showDocumentationADB('numberOfWipeRounds', context);
            },
            child: Text(
              'Number of Wipe Rounds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Row(
          children: [
            //decrement button
            const SizedBox(width: 20),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              //secondary color splash
              splashColor: Theme.of(context).colorScheme.secondary,
              onTap: () {
                swipeProvider.changeWipeRounds(swipeProvider.wipeRounds - 1);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryFixedDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.remove, color: Colors.white),
              ),
            ),

            //display the number of rounds
            Container(
              width: 100,
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${swipeProvider.wipeRounds}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            //increment button
            InkWell(
              splashColor: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                swipeProvider.changeWipeRounds(swipeProvider.wipeRounds + 1);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryFixedDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget globalVerticalSpace() {
  return Column(
    children: [
      const SizedBox(height: 20),
      //divider
      const Divider(thickness: 1),
      const SizedBox(height: 15),
    ],
  );
}

// Placeholder for the missing ClearOrPurgeUi widget
class ClearOrPurgeUi extends StatelessWidget {
  final SwipeProvider swipeProvider;

  const ClearOrPurgeUi(this.swipeProvider, {super.key});

  @override
  Widget build(BuildContext context) {
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
                    title: Text(
                      swipeProvider.isWindows ? 'Use SDelete' : 'Use Nwipe',
                    ),
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

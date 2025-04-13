/*
Here is all the required documentation for the nwipe.
We will use it to only allow the user to erase the removable drives:
Copynwipe [options] [device1] [device2] ...

Options:
  -V, --version           Prints the version number
  -h, --help              Prints this help
  --autonuke              Starts wiping all devices immediately (if no devices are specified)
                          or only the specified devices (if devices are specified)
  --sync                  Open devices in sync mode
  --verify=TYPE           Perform verification of erasure (default: last)
                            off   - Do not verify
                            last  - Verify after the last pass
                            all   - Verify every pass
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe/nwipe_services.dart';
import 'package:swipe/nwipe_ui_screen.dart';

void main() {
  runApp(const MyApp());
}

SwipeProvider swipeProvider = SwipeProvider();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const Swipe(),
    );
  }
}

class Swipe extends StatefulWidget {
  const Swipe({super.key});

  @override
  SwipeState createState() => SwipeState();
}

class SwipeState extends State<Swipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, size: 28),
            const SizedBox(width: 12),
            Text('Swipe - ${swipeProvider.platformName}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('About Swipe'),
                      content: const SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Swipe is a secure drive wiping utility that helps you permanently erase data from storage devices.',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Warning: Data erased with this tool cannot be recovered. Use with caution.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.surface.withAlpha(204), // 0.8 opacity
            ],
          ),
        ),
        child: Center(child: UIContainer()),
      ),
    );
  }
}

class UIContainer extends StatefulWidget {
  const UIContainer({super.key});

  @override
  UIContainerState createState() => UIContainerState();
}

class UIContainerState extends State<UIContainer> {
  bool isRunning = false;
  bool hasTried = false;
  bool hasPassword = true; // Default to true for safety
  bool isCheckingPassword = true; // Flag to show loading while checking
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if the system has a password
    _checkSystemPassword();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSystemPassword() async {
    if (mounted) {
      setState(() {
        isCheckingPassword = true;
      });
    }

    try {
      // For Windows, always set hasPassword to false (no password required)
      // For Linux, check if the system has a password
      if (swipeProvider.isWindows) {
        if (mounted) {
          setState(() {
            hasPassword = false; // Always false for Windows
            isCheckingPassword = false;
          });
        }
      } else {
        // For Linux, check if the system has a password
        final hasSystemPassword = await swipeProvider.hasSystemPassword();
        if (mounted) {
          setState(() {
            hasPassword = hasSystemPassword;
            isCheckingPassword = false;
          });
        }
      }
    } catch (e) {
      // If there's an error and on Linux, assume there is a password for safety
      // If on Windows, still no password required
      if (mounted) {
        setState(() {
          hasPassword =
              !swipeProvider.isWindows; // true for Linux, false for Windows
          isCheckingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => swipeProvider,
      builder: (context, child) {
        return Consumer<SwipeProvider>(
          builder: (context, swipeProvider, child) {
            return SizedBox(
              width: 800,
              height: 600,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App title and description
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Secure Drive Wiper',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Safely and securely erase your drives',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(height: 32),
                          ],
                        ),
                      ),

                      // Authentication section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Show loading indicator while checking if system has password
                              if (isCheckingPassword)
                                Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Checking system configuration...',
                                    ),
                                  ],
                                )
                              // For Windows, always show the Start Application button
                              else if (swipeProvider.isWindows)
                                Card(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          size: 48,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Windows Mode',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'No password required on Windows',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text(
                                            'Start Application',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (isRunning) return;
                                            setState(() {
                                              isRunning = true;
                                            });
                                            // For Windows, we'll just proceed with an empty password
                                            await swipeProvider.checkSudoPswd(
                                              '',
                                            );
                                            await swipeProvider.installNwipe();
                                            if (mounted) {
                                              setState(() {
                                                isRunning = false;
                                                hasTried = true;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              // If Linux, always show password input
                              else if (swipeProvider.isLinux)
                                Card(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Linux Authentication',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: _controller,
                                          obscureText: true, // Hide password
                                          decoration: InputDecoration(
                                            labelText: 'Enter sudo password',
                                            prefixIcon: const Icon(
                                              Icons.lock_outline,
                                            ),
                                            hintText: 'Your sudo password',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Center(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.login),
                                            label: const Text(
                                              'Authenticate & Install Tools',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () async {
                                              if (isRunning) return;
                                              setState(() {
                                                isRunning = true;
                                              });
                                              await swipeProvider.checkSudoPswd(
                                                _controller.text,
                                              );
                                              await swipeProvider
                                                  .installNwipe();
                                              if (mounted) {
                                                setState(() {
                                                  isRunning = false;
                                                  hasTried = true;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Status indicators
                              if (isRunning)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Processing...',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),

                              // Error messages
                              // Only show authentication error for Linux
                              if (hasTried &&
                                  swipeProvider.sudoPassword == '' &&
                                  swipeProvider.isLinux)
                                Card(
                                  color: Colors.red.shade50,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'Authentication failed. Please check your password and try again.',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              if (hasTried && !swipeProvider.nwipeInstalled)
                                Card(
                                  color: Colors.orange.shade50,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'Failed to install required tools. Please try again or check your internet connection.',
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Success message
                              if (hasTried &&
                                  !isRunning &&
                                  swipeProvider.sudoPassword != '' &&
                                  swipeProvider.nwipeInstalled)
                                Card(
                                  color: Colors.green.shade50,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green.shade700,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Setup completed successfully!',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text(
                                            'Proceed to Drive Wiper',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const MainUIScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // System Log section removed
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

class ErrorSudo extends StatelessWidget {
  const ErrorSudo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Error: Incorrect sudo password',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

class NwipeNotInstalled extends StatelessWidget {
  const NwipeNotInstalled({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Error: Nwipe not installed',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

class SuccessUI extends StatelessWidget {
  const SuccessUI({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Success: Nwipe installed',
        style: TextStyle(color: Colors.green),
      ),
    );
  }
}

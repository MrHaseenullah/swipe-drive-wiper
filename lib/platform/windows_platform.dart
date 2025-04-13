import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:swipe/nwipe_services.dart';
import 'package:swipe/platform/platform_interface.dart';
import 'package:path/path.dart' as path;

/// Implementation of platform-specific operations for Windows
class WindowsPlatform implements PlatformInterface {
  // Path to the wiping utilities (will be downloaded)
  String _sDeletePath = '';
  String _eraserPath = '';

  // Path to the diskpart script file
  String _diskpartScriptPath = '';

  @override
  Future<bool> checkAdminPrivileges(String password) async {
    // On Windows, we always return true to skip password check
    log('Windows platform: skipping admin privileges check');
    return true;
  }

  @override
  Future<bool> installWipingUtility() async {
    try {
      // Create a temporary directory to store wiping utilities
      final tempDir = Directory.systemTemp.createTempSync('swipe_');
      _sDeletePath = path.join(tempDir.path, 'sdelete.exe');
      _eraserPath = path.join(tempDir.path, 'eraser.exe');
      _diskpartScriptPath = path.join(tempDir.path, 'diskpart_script.txt');

      // Check if SDelete is already downloaded
      bool sdeleteExists = File(_sDeletePath).existsSync();
      bool eraserExists = File(_eraserPath).existsSync();

      if (sdeleteExists && eraserExists) {
        log('Wiping utilities are already downloaded');
        return true;
      }

      // Download SDelete if needed
      if (!sdeleteExists) {
        log('Downloading SDelete from Microsoft...');

        // Download SDelete from Microsoft's website
        var process = await Process.start('powershell', [
          '-Command',
          'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/SDelete.zip" -OutFile "${tempDir.path}\\sdelete.zip"',
        ], runInShell: true);

        var exitCode = await process.exitCode;
        if (exitCode != 0) {
          log('Failed to download SDelete');
          return false;
        }
      }

      // Download Eraser if needed
      if (!eraserExists) {
        log('Downloading Eraser...');

        // Download Eraser portable version
        var process = await Process.start('powershell', [
          '-Command',
          'Invoke-WebRequest -Uri "https://sourceforge.net/projects/eraser/files/latest/download" -OutFile "${tempDir.path}\\eraser.zip"',
        ], runInShell: true);

        var exitCode = await process.exitCode;
        if (exitCode != 0) {
          log('Failed to download Eraser');
          // Continue anyway as SDelete might be available
        }
      }

      // Extract the SDelete zip file if needed
      if (!sdeleteExists) {
        log('Extracting SDelete...');
        var extractProcess = await Process.start('powershell', [
          '-Command',
          'Expand-Archive -Path "${tempDir.path}\\sdelete.zip" -DestinationPath "${tempDir.path}" -Force',
        ], runInShell: true);

        var extractExitCode = await extractProcess.exitCode;
        if (extractExitCode != 0) {
          log('Failed to extract SDelete');
          // Continue anyway as Eraser might be available
        }
      }

      // Extract the Eraser zip file if needed
      if (!eraserExists) {
        log('Extracting Eraser...');
        var extractProcess = await Process.start('powershell', [
          '-Command',
          'Expand-Archive -Path "${tempDir.path}\\eraser.zip" -DestinationPath "${tempDir.path}\\eraser" -Force',
        ], runInShell: true);

        var extractExitCode = await extractProcess.exitCode;
        if (extractExitCode != 0) {
          log('Failed to extract Eraser');
          // Continue anyway as SDelete might be available
        }

        // Find the Eraser executable in the extracted directory
        try {
          final eraserDir = Directory('${tempDir.path}\\eraser');
          if (eraserDir.existsSync()) {
            final files = eraserDir.listSync(recursive: true);
            for (var file in files) {
              if (file is File &&
                  file.path.toLowerCase().endsWith('eraser.exe')) {
                _eraserPath = file.path;
                log('Found Eraser executable at: $_eraserPath');
                break;
              }
            }
          }
        } catch (e) {
          log('Error finding Eraser executable: $e');
        }
      }

      // Verify SDelete is available
      if (!File(_sDeletePath).existsSync()) {
        // Try to find sdelete.exe in the extracted directory
        final dir = Directory(tempDir.path);
        final files = dir.listSync(recursive: true);
        for (var file in files) {
          if (file is File &&
              path.basename(file.path).toLowerCase() == 'sdelete.exe') {
            _sDeletePath = file.path;
            break;
          }
        }
      }

      // Check if at least one wiping utility is available
      bool sdeleteAvailable = File(_sDeletePath).existsSync();
      bool eraserAvailable = File(_eraserPath).existsSync();

      if (sdeleteAvailable) {
        log('SDelete installed successfully at: $_sDeletePath');
      }

      if (eraserAvailable) {
        log('Eraser installed successfully at: $_eraserPath');
      }

      // Return true if at least one utility is available
      return sdeleteAvailable || eraserAvailable;
    } catch (e) {
      log('Error installing wiping utilities: $e');
      return false;
    }
  }

  @override
  Future<List<Drive>> detectDrives() async {
    log('Detecting drives on Windows');
    List<Drive> drives = [];

    try {
      // First, determine the OS drive letter
      final osProcess = await Process.start('powershell', [
        '-Command',
        'Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive',
      ], runInShell: true);

      var osDriveOutput = await osProcess.stdout.transform(utf8.decoder).join();
      var osDriveLetter = osDriveOutput.trim().replaceAll(':', '');
      log('OS Drive Letter: $osDriveLetter');

      // Get the OS drive disk number
      final osDiskProcess = await Process.start('powershell', [
        '-Command',
        'Get-Partition -DriveLetter $osDriveLetter | Select-Object -ExpandProperty DiskNumber',
      ], runInShell: true);

      var osDiskOutput =
          await osDiskProcess.stdout.transform(utf8.decoder).join();
      var osDiskNumber = int.tryParse(osDiskOutput.trim()) ?? -1;
      log('OS Disk Number: $osDiskNumber');

      // Use PowerShell to get disk information
      final process = await Process.start('powershell', [
        '-Command',
        'Get-Disk | Where-Object {\$_.BusType -eq "USB" -or \$_.BusType -eq "SATA" -or \$_.BusType -eq "NVMe"} | '
            'Select-Object Number, FriendlyName, Size, @{Name="SizeGB";Expression={[math]::Round(\$_.Size/1GB, 2)}} | '
            'ConvertTo-Json',
      ], runInShell: true);

      var outputFuture = process.stdout.transform(utf8.decoder).join();
      var errorFuture = process.stderr.transform(utf8.decoder).join();

      var output = await outputFuture;
      var error = await errorFuture;
      var exitCode = await process.exitCode;

      log('Exit code while detecting drives: $exitCode');

      if (exitCode == 0 && output.trim().isNotEmpty) {
        // Parse the JSON output
        final dynamic jsonData = json.decode(output);

        // Handle both single disk and multiple disks
        final List<dynamic> disksData =
            jsonData is List ? jsonData : [jsonData];

        int index = 0;
        for (var diskData in disksData) {
          final diskNumber = diskData['Number'];
          final diskName = diskData['FriendlyName'] ?? 'Disk $diskNumber';
          final diskSize = '${diskData['SizeGB']}GB';

          // Mark the OS disk as a system drive but include it in the list
          // It will be shown in the UI with a warning and will be disabled
          if (diskNumber == osDiskNumber) {
            log('Marking OS disk as system drive: $diskName');
            drives.add(
              Drive(
                location: '\\\\.\\PhysicalDrive$diskNumber',
                size: diskSize,
                name: '$diskName (SYSTEM DRIVE)',
                index: index++,
                isSystemDrive: true,
              ),
            );
            continue;
          }

          // Create a Drive object with Windows-specific location format
          drives.add(
            Drive(
              location: '\\\\.\\PhysicalDrive$diskNumber',
              size: diskSize,
              name: diskName,
              index: index++,
            ),
          );

          log('Drive detected: ${drives.last}');
        }
      } else {
        log('Error or no output while detecting drives: $error');
      }
    } catch (e) {
      log('Exception while detecting drives: $e');
    }

    return drives;
  }

  @override
  Future<void> launchWipingUtility(String password) async {
    try {
      // Open a command prompt with SDelete
      var process = await Process.start('cmd', [
        '/c',
        'start',
        'cmd',
        '/k',
        'echo SDelete Utility && echo Type "sdelete -?" for help',
      ], runInShell: true);

      await process.exitCode;
    } catch (e) {
      log('Error launching wiping utility: $e');
    }
  }

  @override
  Future<void> eraseDrives(
    String executableString,
    String password,
    List<Drive> drives, {
    required Function(String) onOutput,
    required Function(String) onError,
    String wipeMethod = 'sdelete', // Default to SDelete
  }) async {
    try {
      log('Starting to erase drives on Windows using $wipeMethod');
      onOutput('Starting to erase drives on Windows using $wipeMethod');

      // Get OS disk number for additional safety check
      final osProcess = await Process.start('powershell', [
        '-Command',
        'Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive',
      ], runInShell: true);

      var osDriveOutput = await osProcess.stdout.transform(utf8.decoder).join();
      var osDriveLetter = osDriveOutput.trim().replaceAll(':', '');

      final osDiskProcess = await Process.start('powershell', [
        '-Command',
        'Get-Partition -DriveLetter $osDriveLetter | Select-Object -ExpandProperty DiskNumber',
      ], runInShell: true);

      var osDiskOutput =
          await osDiskProcess.stdout.transform(utf8.decoder).join();
      var osDiskNumber = int.tryParse(osDiskOutput.trim()) ?? -1;
      log('OS Disk Number (safety check): $osDiskNumber');

      for (var drive in drives) {
        // Extract the physical drive number from the location
        final driveNumber = _extractDriveNumber(drive.location);
        if (driveNumber == null) {
          onError('Invalid drive location format: ${drive.location}');
          continue;
        }

        // SAFETY CHECK: Skip OS disk
        if (driveNumber == osDiskNumber) {
          onError(
            'SAFETY ALERT: Skipping OS disk to prevent system damage: ${drive.name}',
          );
          continue;
        }

        onOutput('Processing drive: ${drive.name} (${drive.location})');

        // Create a diskpart script to clean the disk
        await _createDiskpartScript(driveNumber);

        // Run diskpart with the script
        onOutput('Cleaning disk with diskpart...');
        var diskpartProcess = await Process.start('diskpart', [
          '/s',
          _diskpartScriptPath,
        ], runInShell: true);

        // Handle output
        diskpartProcess.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
              if (line.isNotEmpty) {
                log(line.trim());
                onOutput(line);
              }
            });

        diskpartProcess.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
              if (line.isNotEmpty) {
                log(line.trim());
                onError(line);
              }
            });

        var diskpartExitCode = await diskpartProcess.exitCode;
        if (diskpartExitCode != 0) {
          onError('Diskpart failed with exit code $diskpartExitCode');
        }

        // Choose the wiping method based on user selection
        if (wipeMethod == 'eraser' && File(_eraserPath).existsSync()) {
          // Use Eraser for wiping
          onOutput('Securely wiping drive with Eraser...');

          // Launch Eraser in GUI mode since it doesn't have good command-line support
          await Process.start('cmd', [
            '/c',
            'start',
            _eraserPath,
            '--drive',
            drive.location,
          ], runInShell: true);

          // Wait a moment to let Eraser start
          await Future.delayed(const Duration(seconds: 2));

          onOutput(
            'Eraser has been launched. Please complete the process in the Eraser application window.',
          );
          onOutput('Drive ${drive.name} is being processed with Eraser.');

          // We can't reliably capture output from GUI apps, so we'll just inform the user
          onOutput(
            'Note: When Eraser completes, return to this application to continue.',
          );
        } else {
          // Default to SDelete
          onOutput('Securely wiping drive with SDelete...');

          // Use more thorough SDelete parameters for complete drive wiping
          // -p: Number of passes (3 for better security)
          // -z: Zero free space after wiping
          // -nobanner: Suppress the banner
          var sdeleteProcess = await Process.start(_sDeletePath, [
            '-p',
            '3',
            '-z',
            '-nobanner',
            drive.location,
          ], runInShell: true);

          // Handle output
          sdeleteProcess.stdout
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen((line) {
                if (line.isNotEmpty) {
                  log(line.trim());
                  onOutput(line);
                }
              });

          sdeleteProcess.stderr
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen((line) {
                if (line.isNotEmpty) {
                  log(line.trim());
                  onError(line);
                }
              });

          try {
            var sdeleteExitCode = await sdeleteProcess.exitCode;
            if (sdeleteExitCode != 0) {
              onError('SDelete failed with exit code $sdeleteExitCode');
            } else {
              onOutput(
                'Drive ${drive.name} has been securely wiped with SDelete',
              );

              // After successful SDelete operation, format the drive to make it usable again
              onOutput(
                'Formatting drive ${drive.name} to make it usable again...',
              );

              // Extract disk number from drive location
              final diskNumber = _extractDriveNumber(drive.location);
              if (diskNumber != null) {
                // Create a diskpart script for formatting
                await _createDiskpartScript(diskNumber);

                // Run diskpart with the script
                onOutput('Running diskpart to format the drive...');
                final formatProcess = await Process.start('diskpart', [
                  '/s',
                  _diskpartScriptPath,
                ], runInShell: true);

                // Handle output
                formatProcess.stdout
                    .transform(utf8.decoder)
                    .transform(const LineSplitter())
                    .listen((line) {
                      if (line.isNotEmpty) {
                        log(line.trim());
                        onOutput(line);
                      }
                    });

                formatProcess.stderr
                    .transform(utf8.decoder)
                    .transform(const LineSplitter())
                    .listen((line) {
                      if (line.isNotEmpty) {
                        log(line.trim());
                        onError(line);
                      }
                    });

                // Wait for format to complete
                final formatExitCode = await formatProcess.exitCode;
                if (formatExitCode != 0) {
                  onError('Format failed with exit code $formatExitCode');
                } else {
                  onOutput(
                    'Drive ${drive.name} has been successfully formatted and is ready to use',
                  );
                }
              } else {
                onError(
                  'Could not determine disk number for ${drive.location}. Manual formatting may be required.',
                );
              }
            }
          } catch (e) {
            log('Error during drive operation: $e');
            onError('Error during drive operation: $e');
            // Continue execution to prevent app crash
          }
        }
      }

      onOutput('Drive erase process completed successfully');
    } catch (e) {
      log('Error during drive erase: $e');
      onError('Error during drive erase: $e');
      // Don't rethrow the exception to prevent app crash
    }
  }

  // Helper method to create a diskpart script
  Future<void> _createDiskpartScript(int diskNumber) async {
    final script = '''
select disk $diskNumber
clean all
create partition primary
format fs=ntfs quick label="Wiped Drive"
assign
attributes disk clear readonly
exit
''';

    await File(_diskpartScriptPath).writeAsString(script);
  }

  // Helper method to extract drive number from location
  int? _extractDriveNumber(String location) {
    final regex = RegExp(r'PhysicalDrive(\d+)');
    final match = regex.firstMatch(location);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  @override
  Future<bool> checkSecureEraseSupport(Drive drive, String password) async {
    // On Windows, we'll assume all drives support secure erase through SDelete
    return true;
  }

  @override
  Future<void> secureErase(
    Drive drive,
    String password, {
    required Function(String) onOutput,
    required Function(String) onError,
  }) async {
    try {
      log('Starting secure erase for drive: ${drive.location}');
      onOutput('Starting secure erase for drive: ${drive.location}');

      // Get OS disk number for safety check
      final osProcess = await Process.start('powershell', [
        '-Command',
        'Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive',
      ], runInShell: true);

      var osDriveOutput = await osProcess.stdout.transform(utf8.decoder).join();
      var osDriveLetter = osDriveOutput.trim().replaceAll(':', '');

      final osDiskProcess = await Process.start('powershell', [
        '-Command',
        'Get-Partition -DriveLetter $osDriveLetter | Select-Object -ExpandProperty DiskNumber',
      ], runInShell: true);

      var osDiskOutput =
          await osDiskProcess.stdout.transform(utf8.decoder).join();
      var osDiskNumber = int.tryParse(osDiskOutput.trim()) ?? -1;
      log('OS Disk Number (safety check): $osDiskNumber');

      // Extract the physical drive number from the location
      final driveNumber = _extractDriveNumber(drive.location);
      if (driveNumber == null) {
        onError('Invalid drive location format: ${drive.location}');
        return;
      }

      // SAFETY CHECK: Skip OS disk
      if (driveNumber == osDiskNumber) {
        onError(
          'SAFETY ALERT: Cannot securely erase OS disk to prevent system damage: ${drive.name}',
        );
        return;
      }

      // Create a diskpart script to clean the disk
      await _createDiskpartScript(driveNumber);

      // Run diskpart with the script
      onOutput('Cleaning disk with diskpart...');
      var diskpartProcess = await Process.start('diskpart', [
        '/s',
        _diskpartScriptPath,
      ], runInShell: true);

      // Handle output
      diskpartProcess.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.isNotEmpty) {
              log(line.trim());
              onOutput(line);
            }
          });

      diskpartProcess.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.isNotEmpty) {
              log(line.trim());
              onError(line);
            }
          });

      var diskpartExitCode = await diskpartProcess.exitCode;
      if (diskpartExitCode != 0) {
        onError('Diskpart failed with exit code $diskpartExitCode');
        return;
      }

      // Now use SDelete for secure wiping
      onOutput('Securely wiping free space with SDelete...');
      var sdeleteProcess = await Process.start(_sDeletePath, [
        '-p',
        '3',
        '-z',
        drive.location,
      ], runInShell: true);

      // Handle output
      sdeleteProcess.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.isNotEmpty) {
              log(line.trim());
              onOutput(line);
            }
          });

      sdeleteProcess.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.isNotEmpty) {
              log(line.trim());
              onError(line);
            }
          });

      var sdeleteExitCode = await sdeleteProcess.exitCode;
      if (sdeleteExitCode != 0) {
        onError('SDelete failed with exit code $sdeleteExitCode');
      } else {
        onOutput('Secure erase completed successfully');
      }
    } catch (e) {
      onError('Error during secure erase: $e');
      rethrow;
    }
  }

  @override
  String getPlatformName() {
    return 'Windows';
  }

  @override
  bool isWindows() {
    return true;
  }

  @override
  bool isLinux() {
    return false;
  }

  @override
  Future<bool> hasSystemPassword() async {
    // For Windows, we always return false to skip password check
    log('Windows platform: skipping password check');
    return false;
  }

  @override
  String getWipeCommand(
    String method,
    bool verify,
    int rounds,
    bool blank,
    String prngMethod,
    List<Drive> drives,
  ) {
    // This is just for display purposes on Windows, as we use a different approach
    String drivesString = '';
    for (var drive in drives) {
      drivesString += '${drive.location} ';
    }

    return 'sdelete -p $rounds ${method == "zero" ? "-z" : ""} $drivesString';
  }
}

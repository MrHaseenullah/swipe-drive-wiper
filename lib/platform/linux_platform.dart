import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:swipe/nwipe_services.dart';
import 'package:swipe/platform/platform_interface.dart';

/// Implementation of platform-specific operations for Linux
class LinuxPlatform implements PlatformInterface {
  @override
  Future<bool> checkAdminPrivileges(String password) async {
    var process = await Process.start('sudo', [
      '-S',
      'echo',
      'Successfully entered sudo mode',
    ], runInShell: true);

    process.stdin.writeln(password);
    await process.stdin.close();

    process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      log('Successfully entered sudo mode with password $password');
      return true;
    } else {
      log('Error: $error');
      return false;
    }
  }

  @override
  Future<bool> installWipingUtility() async {
    log('Checking nwipe version');
    try {
      var process1 = await Process.start('nwipe', [
        '--version',
      ], runInShell: true);

      var exitCode1 = await process1.exitCode;
      if (exitCode1 == 0) {
        log('nwipe is already installed');
        return true;
      }
    } catch (e) {
      log('nwipe is not installed: $e');
    }

    log('Installing nwipe');
    var process = await Process.start('sudo', [
      '-S',
      'apt',
      'install',
      'nwipe',
    ], runInShell: true);

    process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      log('Successfully installed nwipe');
      return true;
    } else {
      log('Error installing nwipe: $error');
      return false;
    }
  }

  @override
  Future<List<Drive>> detectDrives() async {
    log('Detecting drives on Linux');
    List<Drive> drives = [];

    // Create process to execute command
    final process = await Process.start('sh', [
      '-c',
      'lsblk -o NAME,SIZE -d -p -e 7,11 | grep -E \'sd[b-z]\'',
    ]);

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    log('Exit code while detecting drives: $exitCode');
    log('Output while detecting drives: $output');

    if (exitCode == 0) {
      List<String> lines = output.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          drives.add(Drive.fromLine(lines[i], i));
          log('Drive detected: ${drives.last}');
        }
      }
    } else {
      log('Error detecting drives: $error');
    }

    return drives;
  }

  @override
  Future<void> launchWipingUtility(String password) async {
    var process = await Process.start(
      'gnome-terminal',
      ['--', 'sudo', '-S', 'nwipe'],
      runInShell: true,
      environment: {'TERM': 'xterm'},
    );

    process.stdin.writeln(password);
    await process.stdin.close();

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    await outputFuture;
    await errorFuture;
    await process.exitCode;
  }

  @override
  Future<void> eraseDrives(
    String executableString,
    String password,
    List<Drive> drives, {
    required Function(String) onOutput,
    required Function(String) onError,
    String wipeMethod = '',
  }) async {
    try {
      log('Starting to erase drives on Linux');

      // Force command output to be unbuffered by using script command
      final process = await Process.start(
        'script',
        [
          '--flush', // Force flush after each output
          '--quiet', // Don't show script's startup message
          '--command',
          """sudo -S sh -c "$executableString" """, // erase command
          '/dev/null', // Don't save output to a typescript file
        ],
        runInShell: false, // We don't need shell interpretation here
      );

      // Send password
      process.stdin.writeln(password);
      await process.stdin.close();

      // Handle stdout immediately as it comes
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.isNotEmpty) {
              log(line.trim());
              onOutput(line);
            }
          });

      // Handle stderr immediately as it comes
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (!line.contains('[sudo]') && line.isNotEmpty) {
              log(line.trim());
              onError(line);
            }
          });

      await process.exitCode;
      log('Drive erase process completed');
    } catch (e) {
      log('Error during drive erase: $e');
      onError('Error during drive erase: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkSecureEraseSupport(Drive drive, String password) async {
    log('Checking hdparm for ${drive.location}');
    var process = await Process.start('sudo', [
      '-S',
      'hdparm',
      '-I',
      drive.location,
    ], runInShell: true);

    process.stdin.writeln(password);
    await process.stdin.close();

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      log(output);
      if (output.contains('supported: enhanced erase')) {
        log('hdparm is compatible for ${drive.location}');
        return true;
      } else {
        log('hdparm is not compatible for ${drive.location}');
        return false;
      }
    } else {
      log('Error: $error');
      return false;
    }
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

      // Step 1: Set security password
      var setPassProcess = await Process.start('sudo', [
        'hdparm',
        '--user-master',
        'u',
        '--security-set-pass',
        'p',
        drive.location,
      ]);

      setPassProcess.stdin.writeln(password);
      await setPassProcess.stdin.close();

      // Real-time logging for set password process
      setPassProcess.stdout.transform(utf8.decoder).listen((data) {
        onOutput(data);
      });

      setPassProcess.stderr.transform(utf8.decoder).listen((data) {
        onError(data);
      });

      int setPassExitCode = await setPassProcess.exitCode;
      if (setPassExitCode != 0) {
        throw Exception('Failed to set security password');
      }

      onOutput('Security password set successfully');

      // Step 2: Execute secure erase
      var eraseProcess = await Process.start('sudo', [
        'hdparm',
        '--user-master',
        'u',
        '--security-erase',
        'p',
        drive.location,
      ]);

      // Real-time logging for erase process
      eraseProcess.stdout.transform(utf8.decoder).listen((data) {
        onOutput(data);
      });

      eraseProcess.stderr.transform(utf8.decoder).listen((data) {
        onError(data);
      });

      int eraseExitCode = await eraseProcess.exitCode;
      if (eraseExitCode != 0) {
        throw Exception('Secure erase failed');
      }

      onOutput('Secure erase completed successfully');
    } catch (e) {
      onError('Error during secure erase: $e');
      rethrow;
    }
  }

  @override
  String getPlatformName() {
    return 'Linux';
  }

  @override
  bool isWindows() {
    return false;
  }

  @override
  bool isLinux() {
    return true;
  }

  @override
  Future<bool> hasSystemPassword() async {
    try {
      // On Linux, we'll check if the current user has a password set
      // by looking at the shadow file entry
      final username = Platform.environment['USER'] ?? 'root';

      final process = await Process.start('sh', [
        '-c',
        'grep "^$username:" /etc/shadow | cut -d: -f2',
      ], runInShell: true);

      var output = await process.stdout.transform(utf8.decoder).join();
      var exitCode = await process.exitCode;

      if (exitCode == 0) {
        // If the password field is not empty and not '!' or '*', there's a password
        final hasPassword =
            output.trim().isNotEmpty &&
            output.trim() != '!' &&
            output.trim() != '*';
        log('System has password: $hasPassword');
        return hasPassword;
      } else {
        // If we can't determine, assume there is a password for safety
        log('Could not determine if system has password, assuming it does');
        return true;
      }
    } catch (e) {
      log('Error checking if system has password: $e');
      // If there's an error, assume there is a password for safety
      return true;
    }
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
    String drivesString = '';
    for (var drive in drives) {
      drivesString += '${drive.location} ';
    }

    return 'sudo nwipe --nogui --autonuke '
        '--method=$method '
        '--verify=${verify ? 'all' : 'off'} '
        '--rounds=$rounds '
        '${blank ? '' : '--noblank'} '
        '${(method == 'random') && prngMethod.isNotEmpty ? '--prng=$prngMethod ' : ''}'
        '$drivesString';
  }
}

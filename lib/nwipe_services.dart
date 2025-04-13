/*
Here is all the required documentation for the nwipe.
we will use it to only allow the use to erase the removable drives:
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
  -m, --method=METHOD     The wiping method (default: dodshort)
                            dod522022m / dod       - 7 pass DOD 5220.22-M method
                            dodshort / dod3pass    - 3 pass DOD method
                            gutmann                - Peter Gutmann's Algorithm
                            ops2                   - RCMP TSSIT OPS-II
                            random / prng / stream - PRNG Stream
                            zero / quick           - Overwrite with zeros
  -l, --logfile=FILE      Filename to log to (default is STDOUT)
  -p, --prng=METHOD       PRNG option (mersenne|twister|isaac)
  -r, --rounds=NUM        Number of times to wipe the device (default: 1)
  --noblank               Do not blank disk after wipe (default is to complete a final blank pass)
  --nowait                Do not wait for a key before exiting (default is to wait)
  --nosignals             Do not allow signals to interrupt a wipe (default is to allow)
  --nogui                 Do not show the GUI interface (automatically invokes the nowait option)
                          Must be used with --autonuke option. Send SIGUSR1 to log current stats
  -e, --exclude=DEVICES   Up to ten comma-separated devices to be excluded (examples below)
                            --exclude=/dev/sdc
                            --exclude=/dev/sdc,/dev/sdd
                            --exclude=/dev/sdc,/dev/sdd,/dev/mapper/cryptswap1
To ensure you only select removable drives to be erased/purged:

Run nwipe --autonuke --nogui to start wiping all devices immediately.
Use the --exclude option to exclude any internal drives you don't want to wipe, such as your system drive. For example:
nwipe --autonuke --nogui --exclude=/dev/sda
Verify that the drives being wiped are the ones you want to erase by checking the output or logs.

Remember, the --autonuke option will start wiping immediately, so be sure you have selected the correct drives to exclude before running the command.


sda      8:0    0    25G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
├─sda2   8:2    0     1K  0 part
└─sda5   8:5    0  24.5G  0 part /
sdb      8:16   0 465.8G  0 disk
└─sdb1   8:17   0 465.8G  0 part /media/haseeb/Haseebium
sdc      8:32   1  14.7G  0 disk /media/haseeb/90C5-B628
sr0     11:0    1    57M  0 rom  /media/haseeb/VBox_GAs_7.1.4
sr1     11:1    1  1024M  0 rom



as we know that sda should be excluded by default but we should also give the user the option to select the drives to be excluded.
that includes drives like sdb, sdc and other removable drives.
lsblk -o NAME,SIZE -d -p -e 7,11 | grep -E 'sd[b-z]'

the following command will erase the drive sdb only:
sudo nwipe --nogui --autonuke --method=zero --verify=last /dev/sdb
 */

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:swipe/platform/platform_factory.dart';
import 'package:swipe/platform/platform_interface.dart';

class Drive {
  final String location;
  final String size;
  final int index;
  late final String name;
  bool isWiping = false;
  bool isHDParmCompatable = false;
  bool isSystemDrive = false; // Flag to indicate if this is a system drive

  Drive({
    required this.location,
    required this.size,
    required this.name,
    required this.index,
    this.isSystemDrive = false,
  });

  //to check compatability we need to run:
  //sudo hdparm -I $location and see if the result contains "supported: enhanced erase"

  Future<String> checkHDParmCompatability(String passwd) async {
    log('checking hdparm for $location');
    var process = await Process.start('sudo', [
      '-S',
      'hdparm',
      '-I',
      location,
    ], runInShell: true);

    process.stdin.writeln(passwd);
    await process.stdin.close();

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      //log output
      log(output);
      if (output.contains('supported: enhanced erase')) {
        isHDParmCompatable = true;
        log('hdparm is compatable for $location');
        return output;
      } else {
        isHDParmCompatable = false;
        log('hdparm is not compatable for $location');
        return output;
      }

      //ADD THE ENTIRE OUTPUT TO THE WIPING LOG
    } else {
      log('Error: $error');
    }
    return '';
  }

  //

  /*
  /dev/sda  25G //this is what we should provide to the factory constructor
   */

  factory Drive.fromLine(String line, int index) {
    List<String> parts = line.split(' ');
    String location = parts[0];
    String size = parts.last;
    String name = parts[0].split('/').last;
    return Drive(location: location, size: size, name: name, index: index);
  }

  //override == and hashCode
  @override
  bool operator ==(Object other) {
    if (other is Drive) {
      return other.location == location &&
          other.size == size &&
          other.name == name;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(location, size, name);

  @override
  String toString() {
    return 'Drive: $name, Location: $location, Size: $size';
  }
}

const List<String> eraseMethods = [
  'dod522022m',
  'dodshort',
  'gutmann',
  'ops2',
  'random',
  'zero',
];

const List<String> prngMethods = ['mersenne', 'twister', 'isaac'];

class SwipeProvider extends ChangeNotifier {
  int selectedMethod = 1;
  String logText = '';
  String systemLogText =
      'Application started\nPlatform: ${Platform.operatingSystem}\n'; // For system-level logs that should be shown on both platforms
  bool shouldNwipeOrHdParm = true; //means that we should use nwipe
  String windowsWipeMethod = 'sdelete'; // Options: 'sdelete' or 'eraser'

  // Platform-specific implementation
  final PlatformInterface _platform = PlatformFactory.getPlatform();

  String sudoPassword = '';
  String eraseMethod = 'dodshort';
  bool verifyEnabled = false;
  List<Drive> allDrives = [];
  List<Drive> includedDrives = [];
  int mountedDrives = 0;
  bool nwipeInstalled = false;
  bool blankEnabled = true;
  String prngMethod = '';
  int wipeRounds = 1;
  String executableString = '';

  // Get the platform name
  String get platformName => _platform.getPlatformName();

  // Check if the platform is Windows
  bool get isWindows => _platform.isWindows();

  // Check if the platform is Linux
  bool get isLinux => _platform.isLinux();

  // Check if the system has a password set
  Future<bool> hasSystemPassword() async {
    return await _platform.hasSystemPassword();
  }

  void setNwipeForDrives(bool value) {
    shouldNwipeOrHdParm = value;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void changeEraseMethod(String method) {
    eraseMethod = method;
    notifyListeners();
  }

  void enableVerify(bool value) {
    verifyEnabled = value;
    notifyListeners();
  }

  void changeInclusion(int index) {
    // Skip system drives for safety
    if (allDrives[index].isSystemDrive) {
      log('Prevented inclusion of system drive: ${allDrives[index].name}');
      return;
    }

    if (includedDrives.contains(allDrives[index])) {
      includedDrives.remove(allDrives[index]);
    } else {
      includedDrives.add(allDrives[index]);
    }
    notifyListeners();
  }

  void excludeDrive(int index) {
    includedDrives.removeAt(index);
    notifyListeners();
  }

  void getSudoPassword(String password) {
    sudoPassword = password;
    notifyListeners();
  }

  void startErase() {
    notifyListeners();
  }

  void changeWipeRounds(int rounds) {
    if (rounds > 10 || rounds < 1) return;
    wipeRounds = rounds;
    notifyListeners();
  }

  void enableBlank(bool value) {
    blankEnabled = value;
    notifyListeners();
  }

  void changePRNG(String method) {
    prngMethod = method;
    notifyListeners();
  }

  // Theme toggle removed

  void setWindowsWipeMethod(String method) {
    if (method == 'sdelete' || method == 'eraser') {
      windowsWipeMethod = method;
      notifyListeners();
    }
  }

  void resetWipeCompleted() {
    wipeCompleted = false;
    notifyListeners();
  }

  String setExecutableString() {
    executableString = _platform.getWipeCommand(
      eraseMethod,
      verifyEnabled,
      wipeRounds,
      blankEnabled,
      prngMethod,
      includedDrives,
    );

    log("we have prepared the following command: $executableString");
    notifyListeners();
    return executableString;
  }

  Future<bool> checkSudoPswd(String password) async {
    // For Windows, always succeed regardless of password
    if (isWindows) {
      final logMessage =
          'Windows: No password required, proceeding automatically';
      logText += '$logMessage\n';
      systemLogText += '$logMessage\n';
      notifyListeners();
      log(logMessage);
      sudoPassword =
          'windows_no_password_required'; // Set a non-empty value to indicate success
      return true;
    }

    // For Linux, check the password
    bool success = await _platform.checkAdminPrivileges(password);

    if (success) {
      final logMessage = 'Successfully entered admin mode';
      logText += '$logMessage\n';
      systemLogText += '$logMessage\n';
      notifyListeners();
      log('Successfully entered admin mode with password $password');
      sudoPassword = password;
      return true;
    } else {
      final logMessage = 'Error: Failed to enter admin mode';
      logText += '$logMessage\n';
      systemLogText += '$logMessage\n';
      notifyListeners();
      return false;
    }
  }

  Future<bool> installNwipe() async {
    final installMessage = 'Installing wiping utility...';
    logText += '$installMessage\n';
    systemLogText += '$installMessage\n';
    notifyListeners();

    bool success = await _platform.installWipingUtility();

    if (success) {
      final successMessage = 'Successfully installed wiping utility';
      logText += '$successMessage\n';
      systemLogText += '$successMessage\n';
      notifyListeners();
      log(successMessage);
      nwipeInstalled = true;
      return true;
    } else {
      final errorMessage = 'Error: Failed to install wiping utility';
      logText += '$errorMessage\n';
      systemLogText += '$errorMessage\n';
      notifyListeners();
      return false;
    }
  }

  Future<void> launchNwipe(String password) async {
    try {
      await _platform.launchWipingUtility(password);
      final launchMsg = 'Launched wiping utility';
      logText += '$launchMsg\n';
      systemLogText += '$launchMsg\n';
      notifyListeners();
    } catch (e) {
      final errorMsg = 'Error launching wiping utility: $e';
      logText += '$errorMsg\n';
      systemLogText += '$errorMsg\n';
      notifyListeners();
    }
  }

  // Detect available drives
  Future<void> detectDrives() async {
    // Reset wipeCompleted flag when detecting drives
    wipeCompleted = false;

    // Clear system logs
    logText = '';
    systemLogText = '';
    wipeLogText = '';
    last3Lines = [];

    final detectMsg = 'Detecting drives';
    log(detectMsg);
    logText += '$detectMsg...\n';
    systemLogText += '$detectMsg...\n';
    notifyListeners();

    try {
      // Clear existing drives
      allDrives = [];
      includedDrives = [];
      notifyListeners();

      // Get drives from platform implementation
      allDrives = await _platform.detectDrives();

      if (allDrives.isNotEmpty) {
        final detectedMsg = 'Detected ${allDrives.length} drives';
        logText += '$detectedMsg\n';
        systemLogText += '$detectedMsg\n';

        for (var drive in allDrives) {
          final driveInfo = '${drive.name}: ${drive.size}';
          logText += '$driveInfo\n';
          systemLogText += '$driveInfo\n';
        }
      } else {
        final noDriverMsg = 'No drives detected';
        logText += '$noDriverMsg\n';
        systemLogText += '$noDriverMsg\n';
      }

      notifyListeners();
    } catch (e) {
      final errorMsg = 'Error detecting drives: $e';
      logText += '$errorMsg\n';
      systemLogText += '$errorMsg\n';
      notifyListeners();
    }
  }

  //now we should execute the command to erase the drives:
  /*
  Here is the purpose of the this method:
  a new variable called wipeLogText keeps track of all the logs that are generated during the process of erasing the drives.
  we should create a List<String> last3Lines to keep only the last 3 lines of the log.
  the most recent log string is pushed into the front of the list.

  a new data member called isWiping is set to true to indicate that the drives are being wiped.

   */

  bool isWiping = false;
  String wipeLogText = '';
  List<String> last3Lines = [];
  bool wipeCompleted = false;

  Future<void> eraseDrive(String executableString, String sudoPassword) async {
    // Make sure drives are selected
    if (includedDrives.isEmpty) {
      final noDriverMsg = 'No drives selected for erasure';
      log(noDriverMsg);
      wipeLogText += '\n$noDriverMsg';
      systemLogText += '\n$noDriverMsg';
      notifyListeners();
      return;
    }

    // Reset wipeCompleted flag when starting a new wipe
    wipeCompleted = false;

    // Clear any previous completion messages
    logText = logText.replaceAll('Wipe operation completed successfully', '');
    systemLogText = systemLogText.replaceAll(
      'Wipe operation completed successfully',
      '',
    );
    notifyListeners();

    try {
      isWiping = true;
      final startMsg = 'Starting to erase drives';
      wipeLogText += '\n$startMsg';
      systemLogText += '\n$startMsg';
      log(startMsg);
      notifyListeners();

      // Use platform-specific implementation to erase drives
      await _platform.eraseDrives(
        executableString,
        sudoPassword,
        includedDrives,
        onOutput: (line) {
          if (line.isNotEmpty) {
            wipeLogText += '\n$line';
            systemLogText += '\n$line';
            last3Lines.insert(0, line.trim());
            if (last3Lines.length > 3) last3Lines.removeLast();
            notifyListeners();
          }
        },
        onError: (line) {
          if (line.isNotEmpty) {
            wipeLogText += '\n$line';
            systemLogText += '\n$line';
            last3Lines.insert(0, line.trim());
            if (last3Lines.length > 3) last3Lines.removeLast();
            notifyListeners();
          }
        },
        wipeMethod:
            isWindows
                ? windowsWipeMethod
                : '', // Pass the selected Windows wipe method
      );

      final completeMsg = 'Drive erase process completed successfully';
      wipeLogText += '\n$completeMsg';
      systemLogText += '\n$completeMsg';
      log(completeMsg);
      isWiping = false;

      // Set this flag to true to show the PDF report button
      wipeCompleted = true;

      // Add a clear success message to the logs
      final successMsg = 'Wipe operation completed successfully!';
      wipeLogText += '\n$successMsg';
      systemLogText += '\n$successMsg';
      notifyListeners();
    } catch (e) {
      final errorMsg = 'Error during drive erase: $e';
      wipeLogText += '\n$errorMsg';
      systemLogText += '\n$errorMsg';
      log(errorMsg);
      isWiping = false;
      wipeCompleted = false; // Reset this flag on error
      notifyListeners();

      // Show a more user-friendly error message
      systemLogText +=
          '\nPlease try again or select a different wiping method.';
      notifyListeners();
      // Don't rethrow to prevent app crash
    }
  }

  //a future to start purging and update the logs on the selected
  //here we select the drive and start purging it.
  /*
Here are the commands to first set the passsowrd and then start purding using hdParm:
 sudo hdparm --user-master u --security-set-pass p /dev/sdb
sudo hdparm --user-master u --security-erase p /dev/sdb



 */
  Future<void> startPurge(Drive selectedDrive) async {
    final startMsg =
        'Starting secure erase process for drive: ${selectedDrive.location}';
    log(startMsg);
    try {
      logText += '\n$startMsg\n';
      systemLogText += '\n$startMsg\n';
      notifyListeners();

      // Check if the drive supports secure erase
      bool isSupported = await _platform.checkSecureEraseSupport(
        selectedDrive,
        sudoPassword,
      );

      if (!isSupported && _platform.isLinux()) {
        final notSupportedMsg = 'Drive does not support enhanced secure erase';
        logText += '$notSupportedMsg\n';
        systemLogText += '$notSupportedMsg\n';
        notifyListeners();
        return;
      }

      // Use platform-specific implementation to perform secure erase
      await _platform.secureErase(
        selectedDrive,
        sudoPassword,
        onOutput: (data) {
          logText += data;
          systemLogText += data;
          notifyListeners();
        },
        onError: (data) {
          logText += data;
          systemLogText += data;
          notifyListeners();
        },
      );

      final completeMsg = 'Secure erase completed successfully';
      logText += '$completeMsg\n';
      systemLogText += '$completeMsg\n';
      notifyListeners();
    } catch (e) {
      final errorMsg = 'Error during secure erase: $e';
      logText += '\n$errorMsg\n';
      systemLogText += '\n$errorMsg\n';
      notifyListeners();
      rethrow;
    }
  }
}

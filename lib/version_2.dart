//this is the new architecture of the app.

/*

class Drive {
  final String location;
  final String size;
  final int index;
  late final String name;
  bool isWiping = false;
  bool isHDParmCompatable = false;
  Drive({required this.location, required this.size, required this.name, required this.index});

  //to check compatability we need to run:
  //sudo hdparm -I $location and see if the result contains "supported: enhanced erase"

  Future<void> checkHDParmCompatability(String passwd) async {
    log('checking hdparm for $location');
    var process = await Process.start(
      'sudo',
      ['-S', 'hdparm', '-I', location],
      runInShell: true,
    );

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
      } else {

        isHDParmCompatable = false;
        log('hdparm is not compatable for $location');
      }
    } else {
      log('Error: $error');
    }
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

  //override ==
  @override
  bool operator ==(Object other) {
    if (other is Drive) {
      return other.location == location && other.size == size && other.name == name;
    }
    return false;
  }

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

const List<String> prngMethods = [
  'mersenne',
  'twister',
  'isaac',
];

class SwipeProvider extends ChangeNotifier {
  int selectedMethod = 1;
  String logText = '';
  bool shouldNwipeOrHdParm = true; //means that we should use nwipe


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

  void setNwipeForDrives(bool value) {
    shouldNwipeOrHdParm = value;
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

  String setExecutableString() {
    String drives = '';
    for (int i = 0; i < includedDrives.length; i++) {
      drives += '${includedDrives[i].location} ';
    }

    executableString = 'sudo nwipe --nogui --autonuke '
        '--method=$eraseMethod '
        '--verify=${verifyEnabled ? 'all' : 'off'} '
        '--rounds=$wipeRounds '
        '${blankEnabled ? '' : '--noblank'} '
        '${(eraseMethod == 'random') && prngMethod.isNotEmpty ? '--prng=$prngMethod ' : ''}'
        '$drives';

    log("we have prepared the following command: $executableString");
    notifyListeners();
    return executableString;
  }

  Future<bool> checkSudoPswd(String password) async {
    var process = await Process.start(
      'sudo',
      ['-S', 'echo', 'Successfully entered sudo mode'],
      runInShell: true,
    );

    process.stdin.writeln(password);
    await process.stdin.close();

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      logText += output;
      notifyListeners();
      log('we have successfully entered sudo mode with password $password');
      sudoPassword = password;
      return true;
    } else {
      logText += 'Error: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> installNwipe() async {
    logText += 'Checking nwipe version\n';
    var process1 = await Process.start(
      'nwipe',
      ['--version'],
      runInShell: true,
    );

    logText += process1.stdout.toString();
    notifyListeners();

    var process = await Process.start(
      'sudo',
      ['-S', 'apt', 'install', 'nwipe'],
      runInShell: true,
    );

    process.stdin.writeln(sudoPassword);
    await process.stdin.close();

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      logText += output;
      notifyListeners();
      log('we have successfully installed nwipe');
      nwipeInstalled = true;
      return true;
    } else {
      logText += 'Error: $error';
      notifyListeners();
      return false;
    }
  }

  Future<void> launchNwipe(String password) async {
    var process = await Process.start(
      'gnome-terminal',
      ['--', 'sudo', '-S', 'nwipe'],
      runInShell: true,
      environment: {
        'TERM': 'xterm',
      },
    );

    process.stdin.writeln(password);
    await process.stdin.close();

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    if (exitCode == 0) {
      logText += output;
      notifyListeners();
    } else {
      logText += 'Error: $error';
      notifyListeners();
    }
  }

  //a future to detect the drives:
  Future<void> detectDrives() async {
    log('lets detect the drives');
    //lets execute the command to detect the drives: lsblk -o NAME,SIZE -d -p -e 7,11 | grep -E 'sd[b-z]'

    // Create process to execute command
    final process = await Process.start('sh', ['-c', 'lsblk -o NAME,SIZE -d -p -e 7,11 | grep -E \'sd[b-z]\'']);

    var outputFuture = process.stdout.transform(utf8.decoder).join();
    var errorFuture = process.stderr.transform(utf8.decoder).join();

    var output = await outputFuture;
    var error = await errorFuture;

    var exitCode = await process.exitCode;

    log('Exit code while detecting drives: $exitCode');
    log('Output while detecting drives: $output');
    //right now we are erasing the drives immediately but later we should do it only for the drives that are not
    //in the isWiping state.
      allDrives = [];
      includedDrives = [];
      notifyListeners();

    if (exitCode == 0) {
      List<String> lines = output.split('\n');
      for (int i = 0; i < lines.length - 1; i++) {
        allDrives.add(Drive.fromLine(lines[i], i));
        log('Drive detected: ${allDrives[i]}');
      }
      notifyListeners();
    } else {
      logText += 'Error: $error';
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

  Future<void> eraseDrive(String executableString, String sudoPassword) async {

    //lets make sure that if the selected drives are empty then return 
    if (includedDrives.isEmpty) {
      log('No drives selected for erasure');
      return;
    }


  try {
    wipeLogText += '\nStarting to erase drives';
    log('\nStarting to erase drives');
    notifyListeners();

    // Force command output to be unbuffered by using script command
    final process = await Process.start(
      'script',
      [
        '--flush',          // Force flush after each output
        '--quiet',          // Don't show script's startup message
        '--command',
        """sudo -S sh -c "$executableString" """,  // my erase command
        '/dev/null'         // Don't save output to a typescript file
      ],
      runInShell: false    // We don't need shell interpretation here
    );

    // Send password
    process.stdin.writeln(sudoPassword);
    await process.stdin.close();

    // Handle stdout immediately as it comes
    process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
        if (line.isNotEmpty) {
          wipeLogText += '\n$line';
          log(line.trim());
          last3Lines.insert(0, line.trim());
          if (last3Lines.length > 3) last3Lines.removeLast();
          notifyListeners();
        }
      });

    // Handle stderr immediately as it comes
    process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
        if (!line.contains('[sudo]') && line.isNotEmpty) {
          wipeLogText += '\n$line';
          log(line.trim());
          last3Lines.insert(0, line.trim());
          if (last3Lines.length > 3) last3Lines.removeLast();
          notifyListeners();
        }
      });

    final exitCode = await process.exitCode;

    if (exitCode == 0) {
      wipeLogText += '\nDrive erase process is done.';
      log('\nDrive erase completed successfully with error code =0');
      notifyListeners();
    } else {
      wipeLogText += '\nError during drive erase';
      log('\nError during drive erase');
      notifyListeners();
    }

    log('\nDrive erase completed successfully');
    notifyListeners();

  } catch (e) {
    wipeLogText += '\nError during drive erase: $e';
    log('\nError during drive erase: $e');
    notifyListeners();
    rethrow;
  }
}
}

 */

// instead of keeping most of the logic in the swipeProvider, we
// shift most of the logic inside the DriveProvider class. this is due to the freedom for the drive to manage its state

//here is an interface for the methods in the new DriveProvider class

// Interface for DriveProvider:

abstract class DriveProvider {
  void changeNwipeErase(NwipeDetails settings);
  void enableVerify(bool value);
  void changeInclusion(int index);
  Future<void> startSanitize();
  String setExecutableString();

  Future<void> checkHDParmCompatability(String passwd);

  Future<void> ejectDrive(String location, String sudoPassword);

  Future<void> eraseDrive(String executableString, String sudoPassword);

  String get logText;

  void setError(String error);

  void changeWipeState(bool value);

  Future<bool> checkConnection();

  //factory constructor from string
  // factory DriveProvider.fromLine(String line, int index);
}

class NwipeDetails {
  final String eraseMethod;
  final bool verifyEnabled;
  final bool blankEnabled;
  final String prngMethod;
  final int wipeRounds;
  final String executableString;

  NwipeDetails({
    required this.eraseMethod,
    required this.verifyEnabled,
    required this.blankEnabled,
    required this.prngMethod,
    required this.wipeRounds,
    required this.executableString,
  });
}

abstract class SwipeProvider {
  Future<void> detectDrives();
  Future<void> installNwipe();
  Future<void> launchNwipe(String password);
  Future<void> checkSudoPswd(String password);

  Future<void> installSmartctl();

  void removeDrive(int index);

  void filterDrives();
}

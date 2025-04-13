import 'package:swipe/nwipe_services.dart';

/// Abstract class defining the platform-specific operations
abstract class PlatformInterface {
  /// Check if admin/sudo privileges are available
  Future<bool> checkAdminPrivileges(String password);

  /// Install the wiping utility
  Future<bool> installWipingUtility();

  /// Detect available drives
  Future<List<Drive>> detectDrives();

  /// Launch the wiping utility
  Future<void> launchWipingUtility(String password);

  /// Erase the selected drives
  Future<void> eraseDrives(
    String executableString,
    String password,
    List<Drive> drives, {
    required Function(String) onOutput,
    required Function(String) onError,
    String wipeMethod = '',
  });

  /// Check if a drive supports secure erase
  Future<bool> checkSecureEraseSupport(Drive drive, String password);

  /// Perform secure erase on a drive
  Future<void> secureErase(
    Drive drive,
    String password, {
    required Function(String) onOutput,
    required Function(String) onError,
  });

  /// Get the platform name
  String getPlatformName();

  /// Check if the platform is Windows
  bool isWindows();

  /// Check if the platform is Linux
  bool isLinux();

  /// Check if the system has a password set
  Future<bool> hasSystemPassword();

  /// Get the command to wipe drives
  String getWipeCommand(
    String method,
    bool verify,
    int rounds,
    bool blank,
    String prngMethod,
    List<Drive> drives,
  );
}

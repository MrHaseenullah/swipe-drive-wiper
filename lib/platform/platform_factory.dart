import 'dart:io' as io;

import 'package:swipe/platform/linux_platform.dart';
import 'package:swipe/platform/platform_interface.dart';
import 'package:swipe/platform/windows_platform.dart';

/// Factory class to create the appropriate platform implementation
class PlatformFactory {
  /// Get the platform implementation based on the current platform
  static PlatformInterface getPlatform() {
    if (io.Platform.isWindows) {
      return WindowsPlatform();
    } else if (io.Platform.isLinux) {
      return LinuxPlatform();
    } else {
      throw UnsupportedError('Unsupported platform: ${io.Platform.operatingSystem}');
    }
  }
}

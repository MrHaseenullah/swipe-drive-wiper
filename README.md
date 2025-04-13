# Swipe Drive Wiper

<img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-blue" alt="Platforms">
<img src="https://img.shields.io/badge/Flutter-3.0+-blue" alt="Flutter Version">

A secure drive wiping utility for Windows and Linux, built with Flutter. Swipe Drive Wiper provides a user-friendly interface for securely erasing data from storage devices, making it impossible to recover using standard data recovery tools.

## Features

### Cross-Platform Support
- **Windows**: Uses SDelete (Microsoft) or Eraser for secure wiping
- **Linux**: Uses nwipe or hdparm for secure wiping

### Platform-Specific Features

#### Windows
- No password authentication required
- Simple start button to begin the application
- Protection against wiping system drives
- Windows-specific wiping methods (SDelete and Eraser)

#### Linux
- Password authentication if system has a password
- Support for multiple wiping methods (DoD 5220.22-M, Gutmann, etc.)
- Advanced PRNG options for random wiping

### User Interface
- Clean, modern light theme interface
- Drive detection with clear visual indicators
- Detailed drive information display
- PDF report generation for documentation

### Security Features
- System drive protection to prevent accidental OS destruction
- Multiple wiping standards support
- Verification options

## Installation

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 2.17 or higher
- For Windows: Windows 10 or higher
- For Linux: Ubuntu 20.04 or higher (or equivalent)

### Windows Installation
1. Clone the repository:
   ```
   git clone https://github.com/MrHaseenullah/swipe-drive-wiper.git
   ```
2. Navigate to the project directory:
   ```
   cd swipe-drive-wiper
   ```
3. Get dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run -d windows
   ```

### Linux Installation
1. Clone the repository:
   ```
   git clone https://github.com/MrHaseenullah/swipe-drive-wiper.git
   ```
2. Navigate to the project directory:
   ```
   cd swipe-drive-wiper
   ```
3. Get dependencies:
   ```
   flutter pub get
   ```
4. Install required Linux packages:
   ```
   sudo apt-get update
   sudo apt-get install nwipe hdparm
   ```
5. Run the application:
   ```
   flutter run -d linux
   ```

## Usage

### Windows

1. **Launch the Application**: Run the application and click the "Start Application" button.
2. **Detect Drives**: Click the "Detect Drives" button to scan for connected storage devices.
3. **Select Drives**: Click on the drives you want to wipe. System drives are automatically protected and cannot be selected.
4. **Choose Wiping Method**: Select either SDelete (fast, command-line based) or Eraser (more options, GUI-based).
5. **Start Wiping**: Click the "Securely Erase Selected Drives" button to begin the wiping process.
6. **Generate Report**: After completion, click the "Generate PDF Report" button to create documentation of the wiping process.

### Linux

1. **Launch the Application**: Run the application and enter your system password if prompted.
2. **Detect Drives**: Click the "Detect Drives" button to scan for connected storage devices.
3. **Select Drives**: Click on the drives you want to wipe. System drives are automatically protected and cannot be selected.
4. **Choose Wiping Method**: Select between nwipe and Secure Erase (hdparm).
5. **Configure Wiping Options**: If using nwipe, select the wiping method (DoD 5220.22-M, Gutmann, etc.), number of rounds, and PRNG method if applicable.
6. **Start Wiping**: Click the "Securely Erase Selected Drives" button to begin the wiping process.
7. **Generate Report**: After completion, click the "Generate PDF Report" button to create documentation of the wiping process.

## Wiping Methods

### Windows Methods

- **SDelete (Microsoft)**: A command-line utility that overwrites deleted files' disk space to prevent recovery.
- **Eraser**: A more comprehensive GUI-based tool with multiple wiping algorithms.

### Linux Methods (nwipe)

- **DoD 5220.22-M**: US Department of Defense standard with 3 passes.
- **DoD Short**: A shorter version of the DoD standard.
- **Gutmann**: Peter Gutmann's algorithm with 35 passes.
- **PRNG**: Pseudorandom number generator method with customizable rounds.
- **Zero Fill**: Simple and fast single-pass zero overwrite.

## PDF Report Generation

After completing a drive wipe operation, you can generate a detailed PDF report containing:

- Date and time of the operation
- Drive information (name, size)
- Wiping method used
- Verification results
- System information

This report can be saved to your chosen location and serves as documentation for compliance or verification purposes.

## Safety Features

- **System Drive Protection**: System drives are clearly marked and cannot be wiped to prevent accidental OS destruction.
- **Confirmation Dialogs**: Critical actions require confirmation to prevent accidental data loss.
- **Clear Visual Indicators**: Selected drives are highlighted with distinct colors and icons.

## Project Structure

- `lib/main.dart`: Application entry point and authentication screen
- `lib/nwipe_ui_screen.dart`: Main drive wiping interface
- `lib/nwipe_services.dart`: Core wiping functionality and drive management
- `lib/platform/`: Platform-specific implementations
  - `windows_platform.dart`: Windows-specific wiping methods
  - `linux_platform.dart`: Linux-specific wiping methods
- `lib/pdf_generator.dart`: PDF report generation functionality
- `lib/pdf_report_button.dart`: UI component for PDF report generation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Microsoft for SDelete utility
- nwipe developers for the secure wiping implementation on Linux

## Disclaimer

This software is provided for legitimate data sanitization purposes only. The authors are not responsible for any misuse or data loss. Always verify that you have selected the correct drives before initiating a wipe operation, as the process is irreversible.

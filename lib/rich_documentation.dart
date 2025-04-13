/*
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


this file aims to provide documentation in the form of alert dialogue box which takes in a string argument and outputs a beautiful alert dialogue box with rich text which in turn is placed
in separate const hashmap for easy access and modification.

 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> showDocumentationADB(String infoAbout, BuildContext context) async {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Documentation'),
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              children: <Widget>[
                globalInfoMap[infoAbout]!.animate(
                ).slideY(
                  begin: 0.2,
                  end: 0.0,
                  curve: Curves.easeIn,
                  duration: Duration(milliseconds: 100),
                )
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Map<String, RichText> globalInfoMap = {
  'eraseMethod': RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        // Heading
        TextSpan(
          text: 'About the Wipe Methods\n\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        // Introduction
        TextSpan(
          text: 'These wipe methods are designed to permanently erase data from drives, making it impossible to retrieve. \nDifferent methods prioritize security and speed, so choose carefully based on the level of data confidentiality required:\n\n',
        ),
        // DOD 5220.22-M
        TextSpan(
          text: '• DOD 5220.22-M (dod522022m/dod)\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'This highly secure, 7-pass method follows the rigorous U.S. Department of Defense standards for data sanitization. \nEach pass consists of specific overwriting patterns, including zeros, ones, and random characters. By applying these multiple overwrite passes, DOD 5220.22-M ensures that data recovery is impossible, even with advanced forensic techniques. Ideal for highly sensitive information that must remain unrecoverable under any circumstances.\n\n',
        ),
        // DOD Short
        TextSpan(
          text: '• DOD Short (dodshort/dod3pass)\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'A more time-efficient, 3-pass adaptation of the DOD method. \nWhile shorter, this method still offers robust security by repeatedly overwriting the data, making it unrecoverable for most recovery attempts. This method provides a strong balance between speed and security for sensitive data, ensuring erased information cannot be easily reconstructed.\n\n',
        ),
        // Gutmann
        TextSpan(
          text: '• Gutmann\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'The Gutmann method is a comprehensive 35-pass erasure technique specifically developed for magnetic drives. \nWith complex data patterns distributed across numerous passes, this method is exhaustive in making data retrieval technically impossible, even with advanced recovery technologies. This extreme level of security is suitable for highly confidential or classified data that requires absolute destruction. However, it is very time-intensive.\n\n',
        ),
        // OPS-II
        TextSpan(
          text: '• OPS-II (ops2)\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'Endorsed by the Canadian government, the RCMP TSSIT OPS-II method offers reliable security and efficient operation.\nKnown for its thoroughness, OPS-II is well-suited for environments where data confidentiality is crucial. It ensures data is rewritten in a way that renders it inaccessible, making it an optimal choice for organizations requiring both data protection and procedural efficiency.\n\n',
        ),
        // Random
        TextSpan(
          text: '• Random (random/prng/stream)\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'This single-pass method uses a stream of random data generated by a pseudo-random number generator to overwrite the drive. \nWhile less secure than multi-pass methods, it still provides a sufficient layer of data destruction for lower-risk situations. Once overwritten with random data, retrieval of original information is highly improbable without sophisticated techniques.\n\n',
        ),
        // Zero
        TextSpan(
          text: '• Zero (zero/quick)\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              'The fastest method, this single-pass approach fills the drive with zeros, effectively removing all existing data in a quick manner. \nWhile less secure, it is an efficient choice for basic data removal needs where permanent erasure is needed but confidentiality is not critical. Data overwritten with zeros is effectively irretrievable for casual recovery attempts.\n\n',
        ),
        // Warning
        TextSpan(
          text: 'Warning:\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: 'Data cannot be recovered after using these methods. \nEnsure you have selected the correct drives before proceeding, as the erased data is gone forever.\n\n',
        ),
        // Additional Info
        TextSpan(
          text: 'Verification Options:\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• off: No verification after wiping.\n• last: Verify after the final pass only.\n• all: Verify after every pass.\n\n',
        ),
        TextSpan(
          text: 'PRNG Methods (for Random Erase):\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• mersenne\n• twister\n• isaac\n\n',
        ),
        // Conclusion
        TextSpan(
          text: 'Select a method that best suits your security needs. Each method ensures data is permanently erased, protecting against unauthorized recovery attempts. Make sure your data is securely wiped, and your sensitive information remains irretrievable.',
        ),
      ],
    ),
  ),

// DOD 5220.22-M
  'dod522022m': RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: [
        TextSpan(
          text: "DOD 5220.22-M (dod522022m/dod):\n\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "Highly secure, 7-pass method following rigorous U.S. Department of Defense standards for data sanitization. Each pass uses specific overwriting patterns (zeros, ones, random characters) to ensure data recovery is virtually impossible, even with advanced forensics.\n\n",
        ),
        TextSpan(
          text: "Source: [National Industrial Security Program Operating Manual (NISPOM)](https://www.federalregister.gov/documents/2020/12/21/2020-27698/national-industrial-security-program-operating-manual-nispom)",
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        TextSpan(
          text: "Ideal for: Highly sensitive information requiring absolute unrecoverability.\n\n",
        ),
      ],
    ),
  ),

// DOD Short (DOD 3-pass)
// globalInfoMap.put("dodshort/dod3pass", new RichText(
//label : DOD Short (DOD 3-pass)

  "dodshort": new RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: [
        TextSpan(
          text: "DOD Short (dodshort/dod3pass):\n\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "Time-efficient, 3-pass adaptation of the DOD method. Offers robust security by repeatedly overwriting data, making it unrecoverable for most recovery attempts. Provides a balance between speed and security for moderately sensitive data.\n\n",
        ),
        TextSpan(
          text: "Source: Refer to DOD 5220.22-M documentation for details on the overwriting patterns used.\n\n",
        ),
        TextSpan(
          text: "Ideal for: Moderately sensitive data requiring strong security without excessive wiping time.\n\n",
        ),
      ],
    ),
  ),

// Gutmann
// globalInfoMap.put("gutmann", new RichText(
//label : Gutmann

  "gutmann": new RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: [
        TextSpan(
          text: "Gutmann:\n\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              "Comprehensive 35-pass erasure technique specifically designed for magnetic drives. Uses complex data patterns across numerous passes, making data retrieval technically impossible even with advanced technologies. Ideal for highly confidential data requiring absolute destruction, but very time-intensive.\n\n",
        ),
        TextSpan(
          text: "Source: [Secure Deletion of Data from Magnetic and Solid-State Memory by Peter Gutmann](https://dwaves.de/wp-content/uploads/2015/06/Peter-Gutmann-Secure-Deletion-of-Data-from-Magnetic-and-Solid-State-Memory.pdf)",
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        TextSpan(
          text: "Ideal for: Highly confidential or classified data requiring absolute data destruction.\n\n",
        ),
      ],
    ),
  ),

// OPS-II
// globalInfoMap.put("ops2", new RichText(
//label : OPS-II

  "ops2": new RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: [
        TextSpan(
          text: "OPS-II (ops2):\n\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              "Method endorsed by the Canadian government (RCMP TSSIT OPS-II) offering reliable security and efficient operation. Well-suited for environments where data confidentiality is crucial. Renders data inaccessible, making it ideal for organizations requiring both data protection and procedural efficiency.\n\n",
        ),
        TextSpan(
          text: "Source: [RCMP TSSIT OPS-II](https://www.cse-cst.gc.ca/en/publication/ops-ii)",
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        TextSpan(
          text: "Ideal for: Environments requiring strong data protection and procedural efficiency.\n\n",
        ),
      ],
    ),
  ),

// Random

// globalInfoMap.put("random/prng/stream", new RichText(
//label : Random

  "random": new RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: [
        TextSpan(
          text: "Random (random/prng/stream):\n\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text:
              "Single-pass method using a stream of random data generated by a pseudo-random number generator to overwrite the drive. Provides a sufficient layer of data destruction for lower-risk situations. Once overwritten with random data, retrieval of original information is highly improbable without sophisticated techniques.\n\n",
        ),
        TextSpan(
          text: "Source: [Random Number Generation: Types and Techniques](https://www.geeksforgeeks.org/random-number-generator-types-and-techniques/)",
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        TextSpan(
          text: "Ideal for: Basic data removal needs where permanent erasure is required but confidentiality is not critical.\n\n",
        ),

        //following are the options for the random method
        TextSpan(
          text: "PRNG Methods:\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "• mersenne\n• twister\n• isaac\n\n",
        ),
        // description of the PRNG methods
        //for mersenne
        TextSpan(
          text: "• mersenne:\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "Mersenne Twister is a pseudorandom number generator known for its long period and high quality randomness. It is widely used in scientific computing and simulations due to its excellent statistical properties.\n\n",
        ),

        //for twister
        TextSpan(
          text: "• twister:\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "Twister is a pseudorandom number generator that is fast and has a long period. It is known for its high-quality randomness and is commonly used in various applications.\n\n",
        ),

        //for isaac
        TextSpan(
          text: "• isaac:\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "ISAAC is a pseudorandom number generator designed to be fast and have a long period. It is known for its high-quality randomness and is used in various applications where random numbers are required.\n\n",
        ),
      ],
    ),
  ),

// Zero

// globalInfoMap.put("zero/quick", new RichText(
//label : Zero

  "zero": new RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: [
        TextSpan(
          text: "Zero (zero/quick):\n\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "Fastest method filling the drive with zeros for quick data removal. Efficient choice for basic data removal needs where permanent erasure is required but confidentiality is not critical. Data overwritten with zeros is effectively irretrievable for casual recovery attempts.\n\n",
        ),
        TextSpan(
          text: "Source: [Zero-Filling a Hard Drive](https://www.lifewire.com/zero-filling-hard-drive-2626133)",
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        TextSpan(
          text: "Ideal for: Basic data removal needs where speed is a priority over security.\n\n",
        ),
      ],
    ),
  ),

  //for number of wipeRounds:

  'numberOfWipeRounds': RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        // Heading
        TextSpan(
          text: 'Number of Wipe Rounds\n\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        // Explanation
        TextSpan(
          text: 'The number of wipe rounds specifies how many times the selected erase method is applied over the entire drive. Increasing the number of rounds can enhance the security of data destruction but will also lengthen the wiping process.\n\n',
        ),
        // Details
        TextSpan(
          text: 'For instance, setting the number of rounds to 3 means the drive will be overwritten three times using the chosen wipe method. Each round performs a complete pass, further reducing the possibility of data recovery.\n\n',
        ),
        // When to Adjust
        TextSpan(
          text: 'When to Adjust the Number of Rounds:\n\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• High-Security Requirements: For sensitive data, increasing rounds adds extra layers of security.\n',
        ),
        TextSpan(
          text: '• Standard Data Erasure: One or two rounds may suffice for general purposes where extreme security isn\'t critical.\n\n',
        ),
        // Considerations
        TextSpan(
          text: 'Considerations:\n\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• Time vs. Security: More rounds increase security but also the time required. Balance based on your needs.\n',
        ),
        TextSpan(
          text: '• Drive Wear: Excessive rounds can add unnecessary wear to SSDs and flash drives.\n\n',
        ),
        // Warning
      ],
    ),
  ),

  //lets also document the verification options

  'verificationOptions': RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        // Heading
        TextSpan(
          text: 'Verification Options\n\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        // Explanation
        TextSpan(
          text: 'Verification options determine when and how the erasure process is validated to ensure data destruction is successful. Choose the verification type that best suits your data security needs:\n\n',
        ),
        // Details
        TextSpan(
          text: '• off: No verification is performed after wiping.\n',
        ),
        TextSpan(
          text: '• last: Verification is conducted after the final pass only.\n',
        ),
        TextSpan(
          text: '• all: Verification is performed after every pass.\n\n',
        ),
        // When to Adjust
        TextSpan(
          text: 'When to Adjust the Verification Type:\n\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• High-Security Requirements: Regular verification ensures data is completely erased.\n',
        ),
        TextSpan(
          text: '• Time Constraints: Disabling verification speeds up the erasure process.\n\n',
        ),
        // Considerations
        TextSpan(
          text: 'Considerations:\n\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• Security: Regular verification ensures data is permanently erased.\n',
        ),
        TextSpan(
          text: '• Time: Disabling verification can save time but may compromise data security.\n\n',
        ),
        // Warning
      ],
    ),
  ),

  //lets also document the blanking option

  'blankingOption': RichText(
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        // Heading
        TextSpan(
          text: 'Blanking Option\n\n',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        // Explanation
        TextSpan(
          text: 'The blanking option determines whether the drive is zeroed out after the erasure process is complete. This final blank pass is used for providing an additional layer of data security.\n\n',
        ),
        // Details
        TextSpan(
          text: '• noblank: The drive is not zeroed out after erasure.\n',
        ),
        TextSpan(
          text: '• Default: The drive is zeroed out after the final pass.\n\n',
        ),
        // When to Adjust
        TextSpan(
          text: 'When to Adjust the Blanking Option:\n\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '• High-Security Requirements: Enable blanking to ensure no residual data remains.\n',
        ),
        TextSpan(
          text: '• Time Constraints: Disabling blanking speeds up the erasure process.\n\n',
        ),
        // Considerations
        TextSpan(
          text: 'Considerations:\n\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        TextSpan(
          text: '• Time: Disabling blanking can save time but may compromise data security.\n\n',
        ),
        // Warning
      ],
    ),
  ),
};

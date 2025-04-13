//Here we build beta features page that is gonna contain mock data and ui for the beta features

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:swipe/nwipe_services.dart';

const List<String> waitingMessages = [
  "Erasing your data, please wait...",
  "Wiping the drive clean, hang tight...",
  "Purging your digital past, a moment please...",
  "Sanitizing your storage, just a sec...",
  "Shredding your data, bear with us...",
  "Vaporizing your files, hold on...",
  "Obliterating your old data, one bit at a time...",
  "Disintegrating your digital footprint, please wait...",
  "Annihilating your old files, almost done...",
  "Exterminating your data, nearly finished...",
  "Dissolving your digital self, a few more moments...",
  "Evaporating your data, please be patient...",
  "Clearing the slate, hang tight...",
  "Scrubbing the drive, almost there...",
  "Zeroing out your data, just a little longer...",
  "Deleting the past, one file at a time...",
  "Purging the digital debris, please wait...",
  "Obliterating the obsolete, a moment please...",
  "Vaporizing the vestiges, hang tight...",
  "Eradicating the electronic, almost done...",
  "Exterminating the expired, nearly finished...",
  "Disintegrating the digital detritus, please wait...",
  "Annihilating the antiquated, a moment please...",
  "Vanishing the virtual relics, hang tight...",
  "Obliterating the obsolete data, almost there...",
  "Vaporizing the vestiges of the past, just a little longer...",
  "Eradicating the electronic remnants, please wait...",
  "Exterminating the expired files, a moment please...",
  "Disintegrating the digital debris, hang tight...",
  "Annihilating the antiquated data, almost there...",
  "Vanishing the virtual relics, just a little longer...",
  "Obliterating the obsolete files, please wait...",
  "Vaporizing the vestiges of the past, a moment please...",
  "Eradicating the electronic remnants, hang tight...",
  "Exterminating the expired data, almost there...",
  "Disintegrating the digital debris, just a little longer...",
  "Annihilating the antiquated files, please wait...",
  "Vanishing the virtual relics, a moment please...",
  "Obliterating the obsolete data, hang tight...",
  "Vaporizing the vestiges of the past, almost there...",
  "Eradicating the electronic remnants, just a little longer...",
  "Exterminating the expired files, please wait...",
  "Disintegrating the digital debris, a moment please...",
  "Annihilating the antiquated data, hang tight...",
  "Vanishing the virtual relics, almost there...",
  "Obliterating the obsolete files, just a little longer...",
  "Vaporizing the vestiges of the past, please wait...",
  "Eradicating the electronic remnants, a moment please...",
  "Exterminating the expired data, hang tight...",
];

//a blank scaffold for now
class BetaFeaturesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beta Features')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MajorLoadingContainer(),
              const SizedBox(height: 40),

              //now lets create 3 container in a row each having a flex factor depending on their value
              /*
              the purpose of this container is to show the number of drives that are completed, inProgress and unTouched in terms of wiping.
              //these flexed containers should also have labels as stack and ones that are 0 should not appear.
               */
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: FlexContainer(
                  completedDrives: 5,
                  inProgressDrives: 9,
                  untouchedDrives: 0,
                ),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),

              const SizedBox(height: 40),
              //low lets have a list of drives that are in progress and a few that are completed. we gotta make sure that we display these in beautiful cards
              SingleDrivesList(drives: testDrives),
              //lets put a couple of completed drives
              DriveCard(drive: testDrives[0], isCompleted: true),
              DriveCard(drive: testDrives[1], isCompleted: true),
              const SizedBox(height: 40),
              //lets put a couple of untouched drives
              DriveCard(drive: testDrives[2]),
              DriveCard(drive: testDrives[3]),

              const SizedBox(height: 40),
              //under construction by Haseeb and Haseen-Ullah
              Text('Under Construction by Haseeb and Haseen-Ullah'),
            ],
          ),
        ),
      ),
    );
  }
}
//here is what a drive class looks like:

// class Drive {
//   final String location;
//   final String size;
//   final int index;
//   late final String name;
//   Drive({required this.location, required this.size, required this.name, required this.index});

final testDrives = [
  Drive(location: 'C:', size: '500GB', name: 'sda', index: 1),
  Drive(location: 'D:', size: '1TB', name: 'sdb', index: 2),
  Drive(location: 'E:', size: '2TB', name: 'sdc', index: 3),
  Drive(location: 'F:', size: '500GB', name: 'sdd', index: 4),
  Drive(location: 'G:', size: '1TB', name: 'sde', index: 5),
  Drive(location: 'H:', size: '2TB', name: 'Archive', index: 6),
  Drive(location: 'I:', size: '500GB', name: 'System', index: 7),
  Drive(location: 'J:', size: '1TB', name: 'Storage', index: 8),
  Drive(location: 'K:', size: '2TB', name: 'Library', index: 9),
  Drive(location: 'L:', size: '500GB', name: 'Work', index: 10),
  Drive(location: 'M:', size: '1TB', name: 'Projects', index: 11),
  Drive(location: 'N:', size: '2TB', name: 'Downloads', index: 12),
];

//lets use a listview.builder to display these drives
class SingleDrivesList extends StatelessWidget {
  final List<Drive> drives;

  const SingleDrivesList({required this.drives});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      //this shows a batch of drives that are in progress
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Drives Batch in Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: drives.length - 8,
            itemBuilder: (context, index) {
              return DriveCard(drive: drives[index]);
            },
          ),
        ],
      ),
    );
  }
}

//lets create a card for each drive
class DriveCard extends StatelessWidget {
  final Drive drive;
  final bool isCompleted;

  const DriveCard({required this.drive, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),

      // color: Theme.of(context).colorScheme.secondaryContainer,
      //lets create a gradiant instead from primary to tertiary
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.4),
                Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            //a loading indicator as an avatar
            leading: Container(
              width: 50,
              height: 50,
              child:
                  (isCompleted)
                      ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      )
                      : LoadingAnimationWidget.stretchedDots(
                        color: Colors.white,
                        size: 50,
                      ),
            ),
            title: Text(
              drive.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Size: ${drive.size} | dodShort',
              style: TextStyle(fontSize: 15),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (isCompleted)
                        ? Theme.of(context).colorScheme.primary
                        : null,
                foregroundColor:
                    (isCompleted)
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
              ),
              onPressed: () {},
              child: Text(isCompleted ? 'Completed' : 'Abort'),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FlexContainer extends StatelessWidget {
  final int completedDrives;
  final int inProgressDrives;
  final int untouchedDrives;

  const FlexContainer({
    required this.completedDrives,
    required this.inProgressDrives,
    required this.untouchedDrives,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: completedDrives,
            child: Container(
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Completed: $completedDrives',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: inProgressDrives,
            child: Container(
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'In Progress: $inProgressDrives',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: untouchedDrives,
            child: Container(
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Untouched: $untouchedDrives',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//in the center we shhould have rounded bordered container that contains the loading animation with label under it
//that says Wiping in progress
const double _kSize = 50;

List<Widget> kLoadingAnimations = [
  LoadingAnimationWidget.waveDots(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.inkDrop(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.twistingDots(
    leftDotColor: Colors.white,
    rightDotColor: Colors.white,
    size: _kSize,
  ),
  LoadingAnimationWidget.threeRotatingDots(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.fallingDot(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.progressiveDots(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.discreteCircle(
    color: Colors.white,
    size: _kSize,
    //only blue is acceptable
  ),
  LoadingAnimationWidget.threeArchedCircle(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.bouncingBall(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.flickr(
    leftDotColor: Colors.white,
    rightDotColor: Colors.white,
    size: _kSize,
  ),
  LoadingAnimationWidget.hexagonDots(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.beat(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.twoRotatingArc(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.horizontalRotatingDots(
    color: Colors.white,
    size: _kSize,
  ),
  LoadingAnimationWidget.newtonCradle(color: Colors.white, size: 2 * _kSize),
  LoadingAnimationWidget.stretchedDots(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.halfTriangleDot(color: Colors.white, size: _kSize),
  LoadingAnimationWidget.dotsTriangle(color: Colors.white, size: _kSize),
];

class MajorLoadingContainer extends StatefulWidget {
  @override
  State<MajorLoadingContainer> createState() => _MajorLoadingContainerState();
}

class _MajorLoadingContainerState extends State<MajorLoadingContainer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 7), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget getRandomAnimation() {
    int index = Random().nextInt(kLoadingAnimations.length);
    return kLoadingAnimations[index];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {});
        },
        child: Container(
          width: 500,
          height: 200,
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondaryContainer,
              strokeAlign: BorderSide.strokeAlignCenter,
              width: 5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getRandomAnimation(),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  waitingMessages[Random().nextInt(waitingMessages.length)],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

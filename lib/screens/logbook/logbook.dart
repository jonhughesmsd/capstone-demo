import 'dart:io';

import 'package:capstone/models/log_model.dart';
import 'package:capstone/screens/log/log.dart';
import 'package:capstone/screens/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capstone/singletons/user_data.dart';
import 'package:intl/intl.dart';

class Logbook extends StatefulWidget {
  const Logbook({super.key});

  @override
  State<Logbook> createState() => _LogbookState();
}

class _LogbookState extends State<Logbook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LogBook'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: const Icon(Icons.home_rounded),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: userData.numDives == null || userData.collectionLength == 0
          ? const Center(child: Text('No Recorded Dives Yet'))
          : StreamBuilder<List<LogData>>(
              stream: getLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final logs = snapshot.data!;
                  print('----LOGS LENGTH----');
                  print(logs.length);
                  print('---/LOGS LENGTH----');

                  return ListView(
                    children: logs.map(buildLogTile).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Failed to fetch logs! $snapshot');
                } else {
                  return const Loading();
                }
              },
            ),
    );
  }

  Stream<List<LogData>> getLogs() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userData.uid)
        .collection('logs')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((docSnapshot) => LogData.fromMap(docSnapshot.data()))
            .toList());
  }

  Widget buildLogTile(LogData logData) {

    // TODO remove placeholder text when main section data is required  
    String siteName =
        logData.mainSiteName == "" ? "Unknown Site" : logData.mainSiteName;
    String location =
        logData.mainLocation == "" ? "Unknown Location" : logData.mainLocation;
    String country =
        logData.mainCountry == "" ? "Unknown Country" : logData.mainCountry;
    String date = DateFormat.yMd().format(logData.mainDiveDate);

    final imgFile =
        File('${userData.appDir!.path}/${userData.uid}/${logData.stampPath}');
    final imgFileExists = imgFile.existsSync();

    if (imgFileExists) {
      print('-----IMG FILE EXISTS-----');
      print(logData.stampPath);
      print(imgFile.lengthSync().toString());
    }

    // generate tile with either leading backgroundImage or backgroundColor
    return imgFileExists
        ? ListTile(
            leading: CircleAvatar(
              backgroundImage: FileImage(imgFile),
              child: Stack(
                children: <Widget>[
                  Text(
                    logData.mainDiveNum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = Colors.black,
                    ),
                  ),
                  Text(
                    logData.mainDiveNum,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            title: Text('$siteName - $location'),
            subtitle: Text(country),
            trailing: Text(date),
            onTap: () {
              print("Log: ${logData.mainDiveNum} - $siteName");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Log(prevLogData: logData),
                ),
              );
            },
          )
        : ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.lightBlue.shade50,
              child: Stack(
                children: <Widget>[
                  Text(
                    logData.mainDiveNum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = Colors.black,
                    ),
                  ),
                  Text(
                    logData.mainDiveNum,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            title: Text('$siteName - $location'),
            subtitle: Text(country),
            trailing: Text(date),
            onTap: () {
              print("Log: ${logData.mainDiveNum} - $siteName");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Log(prevLogData: logData),
                ),
              );
            },
          );
  }
}

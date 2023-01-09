import 'package:capstone/screens/shared/loading.dart';
import 'package:capstone/singletons/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogSettings extends StatefulWidget {
  const LogSettings({super.key});

  @override
  State<LogSettings> createState() => _LogSettingsState();
}

class _LogSettingsState extends State<LogSettings> {
  late List<dynamic> sectionList;
  late int numVisible;
  List<bool> visibleList = [];

  bool loading = false;

  Map<String, String> sectionTitles = {
    'timeInOut': 'Time In / Time Out',
    'bottomTime': 'Bottom Time',
    'visibility': 'Visibility',
    'stamp': 'Stamp',
    'depth': 'Depth',
    'gasPressure': 'Cylinder Pressure',
    'weight': 'Weight',
    'temperature': 'Temperature',
    'suit': 'Exposure Suit',
    'weather': 'Weather',
  };

  @override
  void initState() {
    super.initState();
    sectionList = userData.sectionList!;
    numVisible = userData.numVisible!;

    for (int i = 0; i < sectionList.length; i++) {
      visibleList.add(i < numVisible);
    }

  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    child: const Icon(Icons.save_rounded),
                    onTap: () async {
                      setState(() => loading = true);
                      await saveSettings();
                      setState(() => loading = false);
                      Navigator.pop(context);
                    },
                  ),
                ),
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
            body: Container(
              child: getSettingsList(),
            ),
          );
  }

  saveSettings() async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(userData.uid);

    await docUser.update({
      'sectionList': sectionList,
      'numVisible': numVisible,
    });

    userData.sectionList = sectionList;
    userData.numVisible = numVisible;
  }

  Widget getSettingsList() {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) => setState(
        () {
          int index = oldIndex;
          // only reorder visible widgets (except the main widget)
          if (visibleList[oldIndex] && oldIndex != 0 && newIndex != 0) {
            if (newIndex >= numVisible) {
              // keep visible widgets above invisible widgets
              index = numVisible - 1;
            } else if (newIndex > oldIndex) {
              // if widget is moved down the list
              index = newIndex - 1;
            } else {
              // if widget is moved up the list
              index = newIndex;
            }
          }

          final section = sectionList.removeAt(oldIndex);
          sectionList.insert(index, section);
        },
      ),
      itemCount: sectionList.length,
      itemBuilder: (context, index) {
        final section = sectionList[index];
        final isVisible = visibleList[index];
        return buildListContainer(index, section, isVisible);
      },
    );
  }

  Widget buildListContainer(int index, String section, bool isVisible) {
    return section == "mainSection"   // mainSection doesn't get tab or visibility icon
        ? Opacity(
            key: ValueKey(section),
            opacity: 0.6,
            child: getSection(section),
          )
        : Container(
            key: ValueKey(section),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: isVisible
                          ? const Icon(Icons.visibility_rounded)
                          : const Icon(Icons.visibility_off_rounded),
                      color: Colors.blue.shade900,
                      onPressed: () => setState(
                        () {
                          late int newIndex;

                          // move the widget to the bottom of the visible widgets or
                          // the top of the invisible widgets
                          if (isVisible) {
                            newIndex = numVisible - 1;
                            numVisible--;
                            visibleList[numVisible] =
                                false; // assign after decrement
                          } else {
                            newIndex = numVisible;
                            visibleList[numVisible] =
                                true; // assign before increment
                            numVisible++;
                          }

                          final section = sectionList.removeAt(index);
                          sectionList.insert(newIndex, section);
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: Colors.blue.shade900,
                    ),
                    child: Text(
                      sectionTitles[section]!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Opacity(
                  opacity: isVisible ? 0.5 : 0.2,
                  child: getSection(section),
                )
              ],
            ),
          );
  }

  Column getSection(String section) {
    // generate the appropriate widget
    switch (section) {
      case 'mainSection':
        return getMainSection();
      case 'timeInOut':
        return getTimeInOut();
      case 'bottomTime':
        return getBottomTime();
      case 'visibility':
        return getVisibility();
      case 'stamp':
        return getStamp();
      case 'depth':
        return getDepth();
      case 'gasPressure':
        return getGasPressure();
      case 'weight':
        return getWeight();
      case 'temperature':
        return getTemperature();
      case 'suit':
        return getSuit();
      case 'weather':
        return getWeather();
      default:
        return Column(
          children: [
            Text('Error'),
            getDivider(),
          ],
        );
    }
  }

  // These widgets are the same as the ones in log.dart, but without input fields
  // TODO: Is there a way to combine these to limit duplicated code?
  Column getMainSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Text('Dive #', textAlign: TextAlign.center)),
            Expanded(
              child: TextFormField(
                enabled: false,
              ),
            ),
            const Expanded(child: Text('Date', textAlign: TextAlign.center)),
            const Expanded(
              child: TextButton(
                onPressed: null,
                child: Text(' '),
              ),
            ),
          ],
        ),
        Row(
          children: const <Widget>[
            Expanded(child: Text('Site Name', textAlign: TextAlign.center)),
            Expanded(
              child: TextField(
                enabled: false,
              ),
            ),
          ],
        ),
        Row(
          children: const [
            Expanded(child: Text('Location', textAlign: TextAlign.left)),
            Expanded(
              child: TextField(
                enabled: false,
              ),
            ),
          ],
        ),
        Row(
          children: const [
            Expanded(child: Text('Country', textAlign: TextAlign.left)),
            Expanded(
              child: TextField(
                enabled: false,
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getTimeInOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: const [
            Expanded(child: Text('Time In', textAlign: TextAlign.center)),
            Expanded(
              child: IgnorePointer(
                ignoring: true,
                child: TextButton(
                  onPressed: null,
                  child: Text(
                    '12:00',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: const [
            Expanded(child: Text('Time Out', textAlign: TextAlign.center)),
            Expanded(
              child: TextButton(
                onPressed: null,
                child: Text(
                  '12:00',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getBottomTime() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: const [
            Expanded(
              child: Text('Bottom Time', textAlign: TextAlign.center),
            ),
            Expanded(
              child: TextField(
                enabled: false,
              ),
            ),
            Expanded(
              child: IgnorePointer(
                ignoring: true,
                child: Text('mins', textAlign: TextAlign.end),
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getVisibility() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: const [
            Expanded(
              child: Text('Visibility', textAlign: TextAlign.center),
            ),
            Expanded(
              child: TextField(
                enabled: false,
              ),
            ),
            Expanded(
              child: IgnorePointer(
                ignoring: true,
                child: Text('ft/m', textAlign: TextAlign.end),
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getStamp() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/placeholder_stamp.jpeg'),
                    ),
                  ),
                  child: null,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                IgnorePointer(
                  ignoring: true,
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.photo),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(Icons.camera_alt),
                ),
              ],
            )
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getDepth() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Depth', textAlign: TextAlign.start)),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: Text('avg')),
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: IgnorePointer(
                          ignoring: true,
                          child: Text('ft/m', textAlign: TextAlign.end),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(child: Text('max')),
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('ft/m', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getGasPressure() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 100,
                width: 80,
                child: Image.asset(
                  'assets/scubacylinder.png',
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: Text('Start')),
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: IgnorePointer(
                          ignoring: true,
                          child: Text('psi/bar', textAlign: TextAlign.end),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(child: Text('End')),
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('psi/bar', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getWeight() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 70,
                width: 70,
                child: Image.asset(
                  'assets/weight.png',
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ToggleButtons(
                          isSelected: List.generate(3, (_) => false),
                          onPressed: null,
                          children: const <Widget>[
                            Icon(Icons.check_rounded),
                            Icon(Icons.add_rounded),
                            Icon(Icons.remove),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: IgnorePointer(
                          ignoring: true,
                          child: TextField(
                            enabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('lbs/kg', textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text('belt', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('lbs/kg', textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text('BCD', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('lbs/kg', textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text('ankle', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getTemperature() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 120,
                child: Image.asset(
                  'assets/thermometer.png',
                  color: Colors.blue.shade700,
                  scale: 0.8,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: IgnorePointer(
                          ignoring: true,
                          child: Text('Air', textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('Surface', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('Bottom', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getSuit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 300,
                width: 100,
                child: Image.asset(
                  'assets/wetsuit.png',
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            Expanded(
              child: ToggleButtons(
                direction: Axis.vertical,
                isSelected: List.generate(8, (_) => false),
                onPressed: null,
                children: const [
                  Text('none'),
                  Text('short'),
                  Text('full'),
                  Text('F.J.'),
                  Text('top'),
                  Text('boots'),
                  Text('hood'),
                  Text('gloves'),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const IgnorePointer(
                      ignoring: true, child: SizedBox(height: 45)),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: true,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(
                        child: TextField(
                          enabled: false,
                        ),
                      ),
                      Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        getDivider(),
      ],
    );
  }

  Column getWeather() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: ToggleButtons(
            direction: Axis.horizontal,
            isSelected: List.generate(5, (_) => false),
            onPressed: null,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/sun.png',
                  scale: 2,
                  color: Colors.yellow.shade700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/partCloud.png',
                  scale: 2,
                  color: Colors.blueGrey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/cloud.png',
                  scale: 2,
                  color: Colors.blueGrey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/rain.png',
                  scale: 2,
                  color: Colors.blueGrey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/wind.png',
                  scale: 2,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        getDivider(),
      ],
    );
  }

  Divider getDivider() {
    return const Divider(
      height: 40,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey,
    );
  }
}

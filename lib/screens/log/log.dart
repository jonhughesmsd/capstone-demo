import 'dart:io';

import 'package:capstone/models/log_model.dart';
import 'package:capstone/screens/shared/loading.dart';
import 'package:capstone/singletons/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:path/path.dart' as p;

class Log extends StatefulWidget {
  final LogData? prevLogData;

  const Log({Key? key, this.prevLogData}) : super(key: key);

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  final _formKey = GlobalKey<FormState>();

  bool prev = false;

  // For image picker
  XFile? _imageFile;
  dynamic _pickImageError;
  String? _retrieveDataError;
  final ImagePicker _picker = ImagePicker();

  // for loading screen
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    prev = widget.prevLogData != null;

    return KeyboardDismisser(
      gestures: const [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: loading
          ? const Loading()
          : Scaffold(
              appBar: AppBar(
                title: prev ? const Text("Log") : const Text('New Log'),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      child: const Icon(Icons.save_rounded),
                      onTap: () async {
                        setState(() => loading = true);
                        dismissKeyboard();
                        await saveLog();
                        setState(() => loading = false);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  prev
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            child: const Icon(Icons.delete_rounded),
                            onTap: () async {
                              setState(() => loading = true);
                              dismissKeyboard();
                              await deleteLog();
                              setState(() => loading = false);
                              Navigator.pop(context);
                            },
                          ),
                        )
                      : const SizedBox(width: 0),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      child: prev
                          ? const Icon(Icons.arrow_back_rounded)
                          : const Icon(Icons.home_rounded),
                      onTap: () {
                        dismissKeyboard();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              body: userData.sectionList != null
                  ? ListView.builder(
                      itemCount: userData.numVisible,
                      itemBuilder: (context, index) {
                        final sectionName = userData.sectionList![index];
                        return buildSection(index, sectionName);
                      })
                  : const Center(child: Text("Error Loading Log Form")),
            ),
    );
  }

  Widget buildSection(int index, String sectionName) {
    return Container(
      key: ValueKey(sectionName),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: getSection(sectionName),
    );
  }

  Widget getSection(String sectionName) {
    switch (sectionName) {
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
          children: const [Text('error')],
        );
    }
  }

  // hide keyboard when not entering data
  dismissKeyboard() {
    FocusScopeNode currFoc = FocusScope.of(context);
    if (!currFoc.hasPrimaryFocus) {
      currFoc.unfocus();
    }
  }

  // **************************
  // **************************
  /// SAVE
  // **************************
  // **************************

  saveLog() async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(userData.uid);

    if (!prev) {
      userData.collectionLength = userData.collectionLength! + 1;
      userData.numDives = int.parse(mainDiveNumCtrl!.text);
      await userDoc.update({
        'numDives': int.parse(mainDiveNumCtrl!.text),
        'collectionLength': userData.collectionLength,
      });
    }

    // creating map of log data and immediately adding to Firestore
    // this map is not used anywhere else, so it is here instead of log_model.dart
    Map<String, dynamic> logMap = {
      'mainDiveNum': mainDiveNumCtrl!.text,
      'mainDiveDate': date,
      'mainSiteName': mainSiteNameCtrl!.text,
      'mainLocation': mainLocationCtrl!.text,
      'mainCountry': mainCountryCtrl!.text,
      'timeIn': timeIn == null
          ? ''
          : '${timeIn!.hour}:${timeIn!.minute.toString().padLeft(2, '0')}',
      'timeOut': timeOut == null
          ? ''
          : '${timeOut!.hour}:${timeOut!.minute.toString().padLeft(2, '0')}',
      'visibility': visibilityCtrl!.text,
      'bottomTime': bottomTimeCtrl!.text,
      'stampPath': _imageFile == null
          ? ''
          : 'stamps/stamp${mainDiveNumCtrl!.text}${p.extension(_imageFile!.path)}',
      'depthAve': depthAveCtrl!.text,
      'depthMax': depthMaxCtrl!.text,
      'gasPressStart': gasPressStartCtrl!.text,
      'gasPressEnd': gasPressEndCtrl!.text,
      'weightGood': _weights![0],
      'weightAdd': _weights![1],
      'weightMinus': _weights![2],
      'weightChange': weightChangeCtrl!.text,
      'weightBelt': weightBeltCtrl!.text,
      'weightBCD': weightBCDCtrl!.text,
      'weightAnkle': weightAnkleCtrl!.text,
      'tempAir': tempAirCtrl!.text,
      'tempSurface': tempSurfaceCtrl!.text,
      'tempBottom': tempBottomCtrl!.text,
      'suitNone': _suit![0],
      'suitShorty': _suit![1],
      'suitFull': _suit![2],
      'suitFJ': _suit![3],
      'suitTop': _suit![4],
      'suitBoots': _suit![5],
      'suitHood': _suit![6],
      'suitGloves': _suit![7],
      'suitShortyMm': suitShortyCtrl!.text,
      'suitFullMm': suitFullCtrl!.text,
      'suitFJMm': suitFJCtrl!.text,
      'suitTopMm': suitTopCtrl!.text,
      'suitBootsMm': suitBootsCtrl!.text,
      'suitHoodMm': suitHoodCtrl!.text,
      'suitGlovesMm': suitGlovesCtrl!.text,
      'weatherSun': _weather![0],
      'weatherPartCloud': _weather![1],
      'weatherCloud': _weather![2],
      'weatherRain': _weather![3],
      'weatherWind': _weather![4],
    };

    // initialize doc with diveNum as name
    final logDoc =
        userDoc.collection('logs').doc(mainDiveNumCtrl!.text.padLeft(6, '0'));

    // add log to logs collection
    await logDoc.set(logMap);

    // delete dummy data (seemingly no errors for deleting something that isn't there)
    await userDoc.collection('logs').doc("dummy").delete();

    if (_imageFile != null) {
      // upload stamp to storage
      final cachePath = _imageFile!.path;
      final fileExt = p.extension(cachePath);

      final file = File(cachePath);
      final path =
          '${userData.uid}/stamps/stamp${mainDiveNumCtrl!.text}$fileExt';

      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(file);

      // save stamp locally
      // final appDir = await getApplicationDocumentsDirectory();
      final localDir = '${userData.appDir!.path}/${userData.uid}/stamps';
      bool dirExists = await Directory(localDir).exists();
      if (!dirExists) {
        await Directory(localDir).create(recursive: true);
      }
      File localFile =
          await file.copy('$localDir/stamp${mainDiveNumCtrl!.text}$fileExt');

      bool fileExists = await File(localFile.path).exists();
      fileExists ? print('LOCAL SAVE --SUCCESS') : print('LOCAL SAVE --FAIL');
    }

    // print to console for debugging
    _imageFile != null
        ? print(
            "stampPath 'stamps/stamp${mainDiveNumCtrl!.text}${p.extension(_imageFile!.path)}'")
        : print("stampPath --imageFile is null");
  }

  // **************************
  // **************************
  /// DELETE
  // **************************
  // **************************

  deleteLog() async {
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(userData.uid!);

    // decrememnt collectionLength locally and remotely
    userData.collectionLength = userData.collectionLength! - 1;
    await docRef.update({'collectionLength': userData.collectionLength});

    // add dummy to collection -- not working?
    if (userData.collectionLength == 0) {
      final dummyRef = docRef.collection('logs').doc('dummy');
    }

    // delete the remote log
    await docRef
        .collection('logs')
        .doc(widget.prevLogData!.mainDiveNum.padLeft(6, '0'))
        .delete();

    
    // TODO fix deleting remote and local stamp files
    // // delete the remote stamp
    // String stampPath = '${userData.uid}/${widget.prevLogData!.stampPath}';
    // print('-------DELETE STAMPPATH-------');
    // print(stampPath);
    // if (widget.prevLogData!.stampPath != '') {
    //   final fileRef = FirebaseStorage.instance.ref().child(stampPath);
    //   await fileRef.delete();
    // }

    // // delete the local stamp
    // if (_imageFile != null) {
    //   final file = File(_imageFile!.path);
    //   await file.delete();
    // }
  }

  // **************************
  // **************************
  /// CONTROLLERS
  // **************************
  // **************************

  DateTime date = DateTime.now();
  TimeOfDay? timeIn;
  TimeOfDay? timeOut;

  List<bool>? _weights;
  List<bool>? _suit;
  List<bool>? _weather;

  TextEditingController? mainDiveNumCtrl;
  TextEditingController? mainSiteNameCtrl;
  TextEditingController? mainLocationCtrl;
  TextEditingController? mainCountryCtrl;
  TextEditingController? bottomTimeCtrl;
  TextEditingController? visibilityCtrl;
  TextEditingController? depthAveCtrl;
  TextEditingController? depthMaxCtrl;
  TextEditingController? gasPressStartCtrl;
  TextEditingController? gasPressEndCtrl;
  TextEditingController? weightChangeCtrl;
  TextEditingController? weightBeltCtrl;
  TextEditingController? weightBCDCtrl;
  TextEditingController? weightAnkleCtrl;
  TextEditingController? tempAirCtrl;
  TextEditingController? tempSurfaceCtrl;
  TextEditingController? tempBottomCtrl;
  TextEditingController? suitShortyCtrl;
  TextEditingController? suitFullCtrl;
  TextEditingController? suitFJCtrl;
  TextEditingController? suitTopCtrl;
  TextEditingController? suitBootsCtrl;
  TextEditingController? suitHoodCtrl;
  TextEditingController? suitGlovesCtrl;

  @override
  void initState() {
    super.initState();

    // populate the controllers and fields with previously saved data
    // TODO - refactor into one prev == true if statement
    LogData? ld = widget.prevLogData;
    bool prev = ld != null;

    _imageFile = prev && ld.stampPath != ''
        ? XFile('${userData.appDir!.path}/${userData.uid}/${ld.stampPath}')
        : null;

    date = prev ? ld.mainDiveDate : DateTime.now();

    timeIn = prev && ld.timeIn != ''
        ? TimeOfDay(
            hour: int.parse(ld.timeIn.split(':')[0]),
            minute: int.parse(ld.timeIn.split(':')[1]))
        : null;
    timeOut = prev && ld.timeOut != ''
        ? TimeOfDay(
            hour: int.parse(ld.timeOut.split(':')[0]),
            minute: int.parse(ld.timeOut.split(':')[1]))
        : null;

    _weights = prev
        ? [ld.weightGood, ld.weightAdd, ld.weightMinus]
        : List.generate(3, (_) => false);

    _suit = prev
        ? [
            ld.suitNone,
            ld.suitShorty,
            ld.suitFull,
            ld.suitFJ,
            ld.suitTop,
            ld.suitBoots,
            ld.suitHood,
            ld.suitGloves,
          ]
        : List.generate(8, (_) => false);

    _weather = prev
        ? [
            ld.weatherSun,
            ld.weatherPartCloud,
            ld.weatherCloud,
            ld.weatherRain,
            ld.weatherWind,
          ]
        : List.generate(5, (_) => false);

    mainDiveNumCtrl = TextEditingController(
        text: prev ? ld.mainDiveNum : (userData.numDives! + 1).toString());
    mainSiteNameCtrl = prev
        ? TextEditingController(text: ld.mainSiteName)
        : TextEditingController();
    mainLocationCtrl = prev
        ? TextEditingController(text: ld.mainLocation)
        : TextEditingController();
    mainCountryCtrl = prev
        ? TextEditingController(text: ld.mainCountry)
        : TextEditingController();
    bottomTimeCtrl = prev
        ? TextEditingController(text: ld.bottomTime)
        : TextEditingController();
    visibilityCtrl = prev
        ? TextEditingController(text: ld.visibility)
        : TextEditingController();
    depthAveCtrl = prev
        ? TextEditingController(text: ld.depthAve)
        : TextEditingController();
    depthMaxCtrl = prev
        ? TextEditingController(text: ld.depthMax)
        : TextEditingController();
    gasPressStartCtrl = prev
        ? TextEditingController(text: ld.gasPressStart)
        : TextEditingController();
    gasPressEndCtrl = prev
        ? TextEditingController(text: ld.gasPressEnd)
        : TextEditingController();
    weightChangeCtrl = prev
        ? TextEditingController(text: ld.weightChange)
        : TextEditingController();
    weightBeltCtrl = prev
        ? TextEditingController(text: ld.weightBelt)
        : TextEditingController();
    weightBCDCtrl = prev
        ? TextEditingController(text: ld.weightBCD)
        : TextEditingController();
    weightAnkleCtrl = prev
        ? TextEditingController(text: ld.weightAnkle)
        : TextEditingController();
    tempAirCtrl = prev
        ? TextEditingController(text: ld.tempAir)
        : TextEditingController();
    tempSurfaceCtrl = prev
        ? TextEditingController(text: ld.tempSurface)
        : TextEditingController();
    tempBottomCtrl = prev
        ? TextEditingController(text: ld.tempBottom)
        : TextEditingController();
    suitShortyCtrl = prev
        ? TextEditingController(text: ld.suitShortyMm)
        : TextEditingController();
    suitFullCtrl = prev
        ? TextEditingController(text: ld.suitFullMm)
        : TextEditingController();
    suitFJCtrl = prev
        ? TextEditingController(text: ld.suitFJMm)
        : TextEditingController();
    suitTopCtrl = prev
        ? TextEditingController(text: ld.suitTopMm)
        : TextEditingController();
    suitBootsCtrl = prev
        ? TextEditingController(text: ld.suitBootsMm)
        : TextEditingController();
    suitHoodCtrl = prev
        ? TextEditingController(text: ld.suitHoodMm)
        : TextEditingController();
    suitGlovesCtrl = prev
        ? TextEditingController(text: ld.suitGlovesMm)
        : TextEditingController();
  }

  @override
  void dispose() {
    mainDiveNumCtrl!.dispose();
    mainSiteNameCtrl!.dispose();
    mainLocationCtrl!.dispose();
    mainCountryCtrl!.dispose();
    bottomTimeCtrl!.dispose();
    visibilityCtrl!.dispose();
    depthAveCtrl!.dispose();
    depthMaxCtrl!.dispose();
    gasPressStartCtrl!.dispose();
    gasPressEndCtrl!.dispose();
    weightChangeCtrl!.dispose();
    weightBeltCtrl!.dispose();
    weightBCDCtrl!.dispose();
    weightAnkleCtrl!.dispose();
    tempAirCtrl!.dispose();
    tempSurfaceCtrl!.dispose();
    tempBottomCtrl!.dispose();
    suitShortyCtrl!.dispose();
    suitFullCtrl!.dispose();
    suitFJCtrl!.dispose();
    suitTopCtrl!.dispose();
    suitBootsCtrl!.dispose();
    suitHoodCtrl!.dispose();
    suitGlovesCtrl!.dispose();
    super.dispose();
  }

  // TODO fix fetching remote stamp file (currently, only local file is used)
  // Future<XFile> getRemoteStamp(String stampPath) async {
  //   print('------GETTING REMOTE STAMP-------');
  //   print('stampPath: $stampPath');
  //   final localDir = '${userData.appDir!.path}/${userData.uid}/stamps';
  //   bool dirExists = Directory(localDir).existsSync();
  //   if (!dirExists) {
  //     Directory(localDir).createSync(recursive: true);
  //   }

  //   final storageRef =
  //       FirebaseStorage.instance.ref('${userData.uid}/$stampPath');

  //   final path = '${userData.appDir}/${userData.uid}/${stampPath}';
  //   final file = File(path);

  //   storageRef.writeToFile(file);

  //   return XFile(path);
  // }

  // **************************
  // **************************
  /// IMAGE PICKER
  // **************************
  // **************************

  // adapted from https://pub.dev/packages/image_picker/example
  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _imageFile = pickedFile ?? null;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(
        File(_imageFile!.path),
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return getCurrentImage();
    }
  }

  Widget getCurrentImage() {
    if (_imageFile == null) {
      return Container(
        height: 150,
        width: 150,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/placeholder_stamp.jpeg')),
        ),
        child: null,
      );
    } else {
      return Image.file(File(_imageFile!.path));
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file ?? null;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  // **************************
  // **************************
  /// WIDGETS
  // **************************
  // **************************

  // These widgets are the same as the ones in log_settins.dart, but with input controllers
  // TODO: Is there a way to combine these to limit duplicated code?
  Form getMainSection() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
              const Expanded(
                  child: Text('Dive #', textAlign: TextAlign.center)),
              // const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  enabled:
                      false, // disable user ability to change dive num for now
                  controller: mainDiveNumCtrl,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  validator: (value) => value != null ? null : 'Required field',
                ),
              ),
              // const SizedBox(width: 4),
              const Expanded(child: Text('Date', textAlign: TextAlign.center)),
              // const SizedBox(width: 4),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );

                    if (newDate == null) return;

                    setState(() {
                      date = newDate;
                    });
                  },
                  child: Text(
                    '${date.month}/${date.day}/${date.year}',
                    style:
                        const TextStyle(decoration: TextDecoration.underline),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(
                  child: Text('Site Name', textAlign: TextAlign.left)),
              Expanded(
                child: TextFormField(
                    controller: mainSiteNameCtrl,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textAlign: TextAlign.center,
                    validator: (value) =>
                        value != '' ? null : 'Required field'),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(
                  child: Text('Location', textAlign: TextAlign.left)),
              Expanded(
                child: TextFormField(
                    controller: mainLocationCtrl,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textAlign: TextAlign.center,
                    validator: (value) =>
                        value != '' ? null : 'Required field'),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Country', textAlign: TextAlign.left)),
              Expanded(
                child: TextFormField(
                    controller: mainCountryCtrl,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textAlign: TextAlign.center,
                    validator: (value) =>
                        value != '' ? null : 'Required field'),
              ),
            ],
          ),
          getDivider(),
        ],
      ),
    );
  }

  Column getTimeInOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text(
        //   'Time In/Out',
        //   textAlign: TextAlign.start,
        //   style: TextStyle(
        //     color: Colors.grey.shade600,
        //   ),
        // ),
        Row(
          children: [
            const Expanded(child: Text('Time In', textAlign: TextAlign.center)),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: timeIn ?? TimeOfDay.now(),
                  );

                  if (newTime == null) return;

                  setState(() {
                    timeIn = newTime;
                  });
                },
                child: Text(
                  timeIn == null
                      ? ''
                      : '${timeIn!.hour}:${timeIn!.minute.toString().padLeft(2, '0')}',
                  // : '${timeIn!.hour}:${timeNumFormatter.format(timeIn!.minute)}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
                child: Text('Time Out', textAlign: TextAlign.center)),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  TimeOfDay? newTime = await showTimePicker(
                    context: context,
                    initialTime: timeOut ?? timeIn ?? TimeOfDay.now(),
                  );

                  if (newTime == null) return;

                  setState(() {
                    timeOut = newTime;
                  });
                },
                child: Text(
                  timeOut == null
                      ? ''
                      : '${timeOut!.hour}:${timeOut!.minute.toString().padLeft(2, '0')}',
                  // : '${timeOut!.hour}:${timeNumFormatter.format(timeOut!.minute)}',
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
        // Text(
        //   'Bottom Time',
        //   textAlign: TextAlign.start,
        //   style: TextStyle(
        //     color: Colors.grey.shade600,
        //   ),
        // ),
        Row(
          children: [
            const Expanded(
                child: Text('Bottom Time', textAlign: TextAlign.center)),
            Expanded(
              child: TextField(
                key: const ValueKey('bottomTime'),
                controller: bottomTimeCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            const Expanded(child: Text('mins', textAlign: TextAlign.end)),
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
        // Text(
        //   'Visibility',
        //   textAlign: TextAlign.start,
        //   style: TextStyle(
        //     color: Colors.grey.shade600,
        //   ),
        // ),
        Row(
          children: [
            const Expanded(
                child: Text('Visibility', textAlign: TextAlign.center)),
            Expanded(
              child: TextField(
                key: const ValueKey('visibility'),
                controller: visibilityCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            const Expanded(child: Text('ft/m', textAlign: TextAlign.end)),
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
                child: defaultTargetPlatform == TargetPlatform.android
                    ? FutureBuilder<void>(
                        future: retrieveLostData(),
                        builder: (BuildContext context,
                            AsyncSnapshot<void> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return getCurrentImage();
                            case ConnectionState.done:
                              return _previewImages();
                            default:
                              if (snapshot.hasError) {
                                return Text(
                                  'Pick image/video error: ${snapshot.error}}',
                                  textAlign: TextAlign.center,
                                );
                              } else {
                                return getCurrentImage();
                              }
                          }
                        },
                      )
                    : _previewImages(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.gallery);
                    },
                    icon: const Icon(
                      Icons.photo,
                      color: Color.fromARGB(255, 13, 109, 187),
                      size: 40,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      _onImageButtonPressed(ImageSource.camera);
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Color.fromARGB(255, 13, 109, 187),
                      size: 40,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        // Center(
        //   child: Text(_imageFile != null ? _imageFile!.path : "No file yet"),
        // ),
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
                    children: [
                      const Expanded(child: Text('avg')),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('depthAve'),
                          controller: depthAveCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('ft/m', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('max')),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('depthMax'),
                          controller: depthMaxCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
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
                    children: [
                      const Expanded(child: Text('Start')),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('gasPressStart'),
                          controller: gasPressStartCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('psi/bar', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('End')),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('gasPressEnd'),
                          controller: gasPressEndCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
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
                          isSelected: _weights!,
                          onPressed: (index) {
                            setState(() {
                              _weights![index] = !_weights![index];
                            });
                          },
                          children: const <Widget>[
                            Icon(Icons.check_rounded),
                            Icon(Icons.add_rounded),
                            Icon(Icons.remove),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          key: const ValueKey('weightChange'),
                          controller: weightChangeCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('weightBelt'),
                          controller: weightBeltCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('lbs/kg', textAlign: TextAlign.center),
                      ),
                      const Expanded(
                        child: Text('belt', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('weightBCD'),
                          controller: weightBCDCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('lbs/kg', textAlign: TextAlign.center),
                      ),
                      const Expanded(
                        child: Text('BCD', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('weightAnkle'),
                          controller: weightAnkleCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('lbs/kg', textAlign: TextAlign.center),
                      ),
                      const Expanded(
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
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('tempAir'),
                          controller: tempAirCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('Air', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('tempSurface'),
                          controller: tempSurfaceCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('Surface', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('tempBottom'),
                          controller: tempBottomCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
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
                isSelected: _suit!,
                onPressed: (index) {
                  setState(() {
                    _suit![index] = !_suit![index];
                  });
                },
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
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitShorty'),
                          controller: suitShortyCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitFull'),
                          controller: suitFullCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitFJ'),
                          controller: suitFJCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitTop'),
                          controller: suitTopCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitBoots'),
                          controller: suitBootsCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitHood'),
                          controller: suitHoodCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Text('mm', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('suitGloves'),
                          controller: suitGlovesCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
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
            isSelected: _weather!,
            onPressed: (index) {
              setState(() {
                _weather![index] = !_weather![index];
              });
            },
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

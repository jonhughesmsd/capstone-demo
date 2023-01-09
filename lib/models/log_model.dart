import 'package:cloud_firestore/cloud_firestore.dart';

class LogData {
  // all member variables
  String mainDiveNum;
  DateTime mainDiveDate;
  String mainSiteName;
  String mainLocation;
  String mainCountry;
  String timeIn;
  String timeOut;
  String visibility;
  String bottomTime;
  String stampPath;
  String depthAve;
  String depthMax;
  String gasPressStart;
  String gasPressEnd;
  bool weightGood;
  bool weightAdd;
  bool weightMinus;
  String weightChange;
  String weightBelt;
  String weightBCD;
  String weightAnkle;
  String tempAir;
  String tempSurface;
  String tempBottom;
  bool suitNone;
  bool suitShorty;
  bool suitFull;
  bool suitFJ;
  bool suitTop;
  bool suitBoots;
  bool suitHood;
  bool suitGloves;
  String suitShortyMm;
  String suitFullMm;
  String suitFJMm;
  String suitTopMm;
  String suitBootsMm;
  String suitHoodMm;
  String suitGlovesMm;
  bool weatherSun;
  bool weatherPartCloud;
  bool weatherCloud;
  bool weatherRain;
  bool weatherWind;

  LogData({
    // constructor -- all fields are required to maintain consistency
    required this.mainDiveNum,
    required this.mainDiveDate,
    required this.mainSiteName,
    required this.mainLocation,
    required this.mainCountry,
    required this.timeIn,
    required this.timeOut,
    required this.visibility,
    required this.bottomTime,
    required this.stampPath,
    required this.depthAve,
    required this.depthMax,
    required this.gasPressStart,
    required this.gasPressEnd,
    required this.weightGood,
    required this.weightAdd,
    required this.weightMinus,
    required this.weightChange,
    required this.weightBelt,
    required this.weightBCD,
    required this.weightAnkle,
    required this.tempAir,
    required this.tempSurface,
    required this.tempBottom,
    required this.suitNone,
    required this.suitShorty,
    required this.suitFull,
    required this.suitFJ,
    required this.suitTop,
    required this.suitBoots,
    required this.suitHood,
    required this.suitGloves,
    required this.suitShortyMm,
    required this.suitFullMm,
    required this.suitFJMm,
    required this.suitTopMm,
    required this.suitBootsMm,
    required this.suitHoodMm,
    required this.suitGlovesMm,
    required this.weatherSun,
    required this.weatherPartCloud,
    required this.weatherCloud,
    required this.weatherRain,
    required this.weatherWind,
  });

  // convert incoming maps into LogData objects
  static LogData fromMap(Map<String, dynamic> map) {
    LogData ret = LogData(
      mainDiveNum: map['mainDiveNum'],
      mainDiveDate: (map['mainDiveDate'] as Timestamp).toDate(),
      mainSiteName: map['mainSiteName'],
      mainLocation: map['mainLocation'],
      mainCountry: map['mainCountry'],
      timeIn: map['timeIn'],
      timeOut: map['timeOut'],
      visibility: map['visibility'],
      bottomTime: map['bottomTime'],
      stampPath: map['stampPath'],
      depthAve: map['depthAve'],
      depthMax: map['depthMax'],
      gasPressStart: map['gasPressStart'],
      gasPressEnd: map['gasPressEnd'],
      weightGood: map['weightGood'] as bool,
      weightAdd: map['weightAdd'] as bool,
      weightMinus: map['weightMinus'] as bool,
      weightChange: map['weightChange'],
      weightBelt: map['weightBelt'],
      weightBCD: map['weightBCD'],
      weightAnkle: map['weightAnkle'],
      tempAir: map['tempAir'],
      tempSurface: map['tempSurface'],
      tempBottom: map['tempBottom'],
      suitNone: map['suitNone'] as bool,
      suitShorty: map['suitShorty'] as bool,
      suitFull: map['suitFull'] as bool,
      suitFJ: map['suitFJ'] as bool,
      suitTop: map['suitTop'] as bool,
      suitBoots: map['suitBoots'] as bool,
      suitHood: map['suitHood'] as bool,
      suitGloves: map['suitGloves'] as bool,
      suitShortyMm: map['suitShortyMm'],
      suitFullMm: map['suitFullMm'],
      suitFJMm: map['suitFJMm'],
      suitTopMm: map['suitTopMm'],
      suitBootsMm: map['suitBootsMm'],
      suitHoodMm: map['suitHoodMm'],
      suitGlovesMm: map['suitGlovesMm'],
      weatherSun: map['weatherSun'] as bool,
      weatherPartCloud: map['weatherPartCloud'] as bool,
      weatherCloud: map['weatherCloud'] as bool,
      weatherRain: map['weatherRain'] as bool,
      weatherWind: map['weatherWind'] as bool,
    );

    return ret;
  }
}

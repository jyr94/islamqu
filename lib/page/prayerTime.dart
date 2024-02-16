import 'package:flutter/material.dart';
import 'package:islamqu/helper/NotificationService.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:islamqu/model/prayerTime.dart';
import 'package:islamqu/helper/utils.dart';
import 'package:islamqu/helper/constant.dart';

class PrayerTime extends StatefulWidget {
  PrayerTime({Key? key}) : super(key: key);
  @override
  _PrayerTimeState createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  String? _test;
  SharedPreferences? preferences;
  String? _nextPrayerName;
  String? _nextPrayer;
  PrayerTimes? _prayerTimes;
  final _prayerTimeModel= PrayerTimeModel();
  int currentPage=0;
  String? _datePrayer;

  DateTime now =new DateTime.now();
  ///Page Controller for the PageView
  final controller = PageController(
    initialPage: 0,
  );

  Future<void>initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
    this.preferences?.setString("name", "Peter");
  }
  Future<void> _getPrayTime(double? latitude,longitude) async {
    // print('testing,$latitude');
    final myCoordinates =
    Coordinates(latitude!,longitude!); // Replace with your own location lat, lng.
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    print('_getPrayTime');

    if (currentPage>0){
      print(currentPage);
      final nextDay=now.add(Duration(days: currentPage));
      final date = DateComponents.from(nextDay);

      _datePrayer=dateFormatter(nextDay);
      _prayerTimes = PrayerTimes.utc(myCoordinates, date,params);
      print(_datePrayer);
      print(_prayerTimes?.dhuhr);
    }else{
      final date = DateComponents.from(now);
      _datePrayer=dateFormatter(now);
      _prayerTimes = PrayerTimes.utc(myCoordinates,date, params);
      final test = PrayerTimes.today(myCoordinates, params);
      print(test.asr);
    }



  }
  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete((){
      setState(() {
        _getPrayTime(preferences?.getDouble("_preflatitude"),preferences?.getDouble("_preflongitude"));
        print(_prayerTimeModel.datePrayer);
        // _getPrayTime(preferences?.getDouble("_preflatitude"), preferences?.getDouble("_preflongitude"));
      });
    });

  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Column(children: [
          Text(
            "Jadwal Sholat",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),
          ),
        Text(
          preferences?.getString("_prefCurrentAddress") ?? "",style: TextStyle(color: mainColor,fontSize: 12),
        ),
        ]),
      ),
      ///A Page View with 3 children
      body: PageView(
        controller: controller,
        scrollDirection:  Axis.horizontal,
        onPageChanged: (page){
          currentPage=page;
          setState(() {
            _getPrayTime(preferences?.getDouble("_preflatitude"),
                preferences?.getDouble("_preflongitude"));
          });
        },
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.only(top: 24,left: 24,right: 24,bottom: 250),
              child:ListView(children: <Widget>[
                Center(
                    child: Text(
                      _datePrayer ?? "",
                      // 'test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Sholat')),
                    DataColumn(label: Text('Waktu')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Shubuh')),
                      DataCell(Text(_prayerTimes?.fajr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.fajr.toLocal()))),

                    ]),
                    DataRow(cells: [
                      DataCell(Text('dhuhr')),
                      DataCell(Text(_prayerTimes?.dhuhr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.dhuhr.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('azhar')),
                      DataCell(Text(_prayerTimes?.asr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.asr.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('maghrib')),
                      DataCell(Text(_prayerTimes?.maghrib==null ? '-' : DateFormat.Hm().format(_prayerTimes!.maghrib.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('isha')),
                      DataCell(Text(_prayerTimes?.isha==null ? '-' : DateFormat.Hm().format(_prayerTimes!.isha.toLocal()))),
                    ]),

                  ],
                ),
              ]

            ),
          ),
          ),
          Container(
            color: Colors.white,
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.only(top: 24,left: 24,right: 24,bottom: 250),
              child:ListView(children: <Widget>[
                Center(
                    child: Text(
                      _datePrayer ?? "",
                      // 'test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Sholat')),
                    DataColumn(label: Text('Waktu')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Shubuh')),
                      DataCell(Text(_prayerTimes?.fajr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.fajr.toLocal()))),

                    ]),
                    DataRow(cells: [
                      DataCell(Text('dhuhr')),
                      DataCell(Text(_prayerTimes?.dhuhr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.dhuhr.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('azhar')),
                      DataCell(Text(_prayerTimes?.asr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.asr.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('maghrib')),
                      DataCell(Text(_prayerTimes?.maghrib==null ? '-' : DateFormat.Hm().format(_prayerTimes!.maghrib.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('isha')),
                      DataCell(Text(_prayerTimes?.isha==null ? '-' : DateFormat.Hm().format(_prayerTimes!.isha.toLocal()))),
                    ]),

                  ],
                ),
              ]
            ),
          ),
          ),
          Container(
            color: Colors.white,
            child: Card(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.only(top: 24,left: 24,right: 24,bottom: 250),
              child:ListView(children: <Widget>[
                Center(
                    child: Text(
                      _datePrayer ?? "",
                      // 'test',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),

                DataTable(
                  columns: [
                    DataColumn(label: Text('Sholat')),
                    DataColumn(label: Text('Waktu')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Shubuh')),
                      DataCell(Text(_prayerTimes?.fajr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.fajr.toLocal()))),

                    ]),
                    DataRow(cells: [
                      DataCell(Text('dhuhr')),
                      DataCell(Text(_prayerTimes?.dhuhr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.dhuhr.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('azhar')),
                      DataCell(Text(_prayerTimes?.asr==null ? '-' : DateFormat.Hm().format(_prayerTimes!.asr.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('maghrib')),
                      DataCell(Text(_prayerTimes?.maghrib==null ? '-' : DateFormat.Hm().format(_prayerTimes!.maghrib.toLocal()))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('isha')),
                      DataCell(Text(_prayerTimes?.isha==null ? '-' : DateFormat.Hm().format(_prayerTimes!.isha.toLocal()))),
                    ]),

                  ],
                ),
              ]
            ),
          ),
          ),
        ],

      ),

    );
  }
}
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
  final _prayerTimeModel = PrayerTimeModel();
  int currentPage = 0;
  static const int _totalPages = 3;
  final Map<int, _PrayerPageData> _prayerDataCache = {};
  Coordinates? _coordinates;
  late final CalculationParameters _calculationParameters;

  DateTime now = DateTime.now();
  ///Page Controller for the PageView
  final controller = PageController(
    initialPage: 0,
  );

  Future<void> initializePreference() async {
    preferences = await SharedPreferences.getInstance();
    preferences?.setString("name", "Peter");
  }

  void _initializePrayerConfig() {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    _calculationParameters = params;
  }

  void _cachePrayerData(int page) {
    if (_coordinates == null || _prayerDataCache.containsKey(page)) {
      return;
    }
    final targetDate = now.add(Duration(days: page));
    final dateComponents = DateComponents.from(targetDate);
    final prayerTimes = PrayerTimes.utc(
      _coordinates!,
      dateComponents,
      _calculationParameters,
    );
    _prayerDataCache[page] = _PrayerPageData(
      date: dateFormatter(targetDate),
      prayerTimes: prayerTimes,
    );
  }

  void _initializePrayerData() {
    final latitude = preferences?.getDouble("_preflatitude");
    final longitude = preferences?.getDouble("_preflongitude");
    if (latitude != null && longitude != null) {
      setState(() {
        _coordinates = Coordinates(latitude, longitude);
        _cachePrayerData(currentPage);
      });
    } else {
      setState(() {});
    }
  }
  @override
  void initState() {
    super.initState();
    _initializePrayerConfig();

    initializePreference().then((_) {
      if (!mounted) return;
      _initializePrayerData();
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Jadwal Sholat",
              style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
            ),
            Text(
              preferences?.getString("_prefCurrentAddress") ?? "",
              style: TextStyle(color: mainColor, fontSize: 12),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
            _cachePrayerData(page);
          });
        },
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          final data = _prayerDataCache[index];
          if (data == null) {
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildPrayerCard(
            date: data.date,
            prayerTimes: data.prayerTimes,
          );
        },
      ),

    );
  }

  Widget _buildPrayerCard({
    required String date,
    required PrayerTimes prayerTimes,
  }) {
    return Container(
      color: Colors.white,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 250),
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(
                date,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            DataTable(
              columns: const [
                DataColumn(label: Text('Sholat')),
                DataColumn(label: Text('Waktu')),
              ],
              rows: [
                _buildPrayerRow('Shubuh', prayerTimes.fajr),
                _buildPrayerRow('dhuhr', prayerTimes.dhuhr),
                _buildPrayerRow('azhar', prayerTimes.asr),
                _buildPrayerRow('maghrib', prayerTimes.maghrib),
                _buildPrayerRow('isha', prayerTimes.isha),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildPrayerRow(String title, DateTime time) {
    return DataRow(
      cells: [
        DataCell(Text(title)),
        DataCell(Text(_formatPrayerTime(time))),
      ],
    );
  }

  String _formatPrayerTime(DateTime prayerTime) {
    return DateFormat.Hm().format(prayerTime.toLocal());
  }
}

class _PrayerPageData {
  final String date;
  final PrayerTimes prayerTimes;

  _PrayerPageData({
    required this.date,
    required this.prayerTimes,
  });
}

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:core';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:islamqu/helper/NotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:islamqu/api/prayer.dart';
import 'package:islamqu/model/prayer.dart';
import 'dart:convert';
import 'package:islamqu/page/dailyPrayerDetail.dart';
import 'package:islamqu/page/qiblah.dart';
import 'package:islamqu/page/daily_prayer.dart';
import 'package:islamqu/helper/SquareButton.dart';
import 'package:islamqu/helper/utils.dart';
import 'package:islamqu/helper/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamqu/api/surah.dart';
import 'package:islamqu/page/list_surah.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:islamqu/helper/analytics.dart';
// import 'package:number_to_word_arabic/number_to_word_arabic.dart';
import 'package:islamqu/helper/utils.dart';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:islamqu/page/prayerTime.dart';
import 'package:islamqu/page/Home.dart';
import 'package:islamqu/helper/constant.dart';
import 'package:tuple/tuple.dart';
import 'package:app_settings/app_settings.dart';
import 'package:islamqu/model/Tuple2.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);
  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  NotificationService _notificationService = NotificationService();
  TextEditingController editingController = TextEditingController();
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  SharedPreferences? preferences;

  String? _currentAddress;
  Position? _currentPosition;
  String? _nextPrayer;
  String? _nextPrayerName;
  String? _city;
  String? _name;
  bool isSwitchedShubuh = false;
  bool isSwitchedzuhur = false;
  bool isSwitchedashar = false;
  bool isSwitchedmakrib = false;
  bool isSwitchedisya = false;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.adaptiveBannerAdUnitId,
      request: AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print(err);
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  Future<void> initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      print(position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    // print(position);
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      final myCoordinates = Coordinates(
          _currentPosition!.latitude,
          _currentPosition!
              .longitude); // Replace with your own location lat, lng.
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      setState(() {
        _currentAddress = '${place.subAdministrativeArea}';
        _city = '${place.subLocality}';

        // _prefs.setString('_prefCurrentAddress', _currentAddress);
        this
            .preferences
            ?.setString('_prefCurrentAddress', _currentAddress ?? "-");
        this.preferences?.setString('_city', _city ?? "");
        this
            .preferences
            ?.setDouble('_preflatitude', _currentPosition!.latitude);
        this
            .preferences
            ?.setDouble('_preflongitude', _currentPosition!.longitude);
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> requestLocation() async {
    if (await Permission.location.isDenied  || await Permission.notification.isPermanentlyDenied  || await Permission.notification.isRestricted) {
      await Permission.location.request();
    }
    if (await Permission.location.isGranted) {
      await _getCurrentPosition().whenComplete(() {
        return true;
      });
    }
    return false;
  }
  Future<bool> _permission() async {
    if (await Permission.notification.isDenied || await Permission.notification.isPermanentlyDenied) {
      print("okaaaa");
      await Permission.notification.request();
      // return Future.value(false);
    }else if( await Permission.notification.isGranted){
      print("isGranted");
      return Future.value(true);
    }

    if (await Permission.notification.status.isPermanentlyDenied){
      print("sini oyy");
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
    print(await Permission.notification.status);
    return Future.value(false);
  }
  Future<PrayerTimes> prayertime() async {
    final myCoordinates = Coordinates(
        this.preferences!.getDouble('_preflatitude')!,
        this.preferences!.getDouble('_preflongitude')!);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);
    return prayerTimes;
  }
  // Tuple2<bool, String> resultAdzan(bool status,String message) {
  //   return new Tuple2(status, message);
  // }
  Future<void> NotifTest() async {
    // var result = DateTime.now().add(Duration(minutes: 2));
    // _notificationService.scheduleNotification(
    //     id: 9,
    //     title: "shubuh",
    //     body: "shubuh",
    //     scheduledNotificationDateTime: result);
    // print(result);
    _notificationService.cancelNotifications(9);
  }

  Future<Tuple2<bool, String>> setAdzanShubuh(bool value) async {

    if (this.preferences?.getDouble('_preflatitude') == null) {
      print("errorsss");
      return  Tuple2(false, "Aktifkan Lokasi Dahulu");
    }

   var test= await _permission().then((v){
      print('permision,$v');
      if (v){
        print("masuk true");
        prayertime().then((ps) {
          DateTime? now = DateTime.now();
          if (value) {

            var fajr = DateTime(
                now.year, now.month, now.day, ps.fajr.hour, ps.fajr.minute);
            _notificationService.scheduleNotification(
                id: 1,
                title: "shubuh",
                body: "shubuh",
                scheduledNotificationDateTime: fajr);
            print("done set notifi");
            print(fajr);
            // return resp.;
            // return resp(true,"");
            return Tuple2(false, "");
          } else {
            _notificationService.cancelNotifications(1);
            print("done remove notifi");
            // return resp(true,"");
            return Tuple2(true, "");
          }
        });
      }else{
        // return resp(false,"Izinkan Pemberitahuan");
        return Tuple2(false, "Izinkan Pemberitahuan");
      }
      // return resp(true,"");
      return Tuple2(true, "");

    });
    return Future.value(test);

  }

  Future<Tuple2<bool, String>> setAdzanZuhur(bool value) async{
    if (this.preferences?.getDouble('_preflatitude') == null) {
      print("errorsss");
      return Tuple2(false, "Aktifkan Lokasi Dahulu!!");
    }
    // var ps=prayertime();
    var result= await _permission().then((v){
      if (v){
        prayertime().then((ps) {
          DateTime? now = DateTime.now();
          if (value) {
            var dhuhr = DateTime(
                now.year, now.month, now.day, ps.dhuhr.hour, ps.dhuhr.minute);
            _notificationService.scheduleNotification(
                id: 2,
                title: "dhuhr",
                body: "dhuhr",
                scheduledNotificationDateTime: dhuhr);
            print("done set notifi zuhur");
            return Tuple2(true, "");
          } else {
            _notificationService.cancelNotifications(2);
            print("done remove notifi zuhur");
            return Tuple2(true, "");
          }
        });
      }else{
        return Tuple2(false, "Izinkan Pemberitahuan");
      }
      return Tuple2(true, "");

    });
    return Future.value(result);
  }

  Future<Tuple2<bool, String>> setAdzanAshar(bool value) async {
    print(this.preferences?.getDouble('_preflatitude'));
    if (this.preferences?.getDouble('_preflatitude') == null) {
      print("errorsss");
      return Tuple2(false, "Aktifkan Lokasi Dahulu");
    }
    // var ps=prayertime();
   var result= await _permission().then((v){
      if (v){
        prayertime().then((ps) {
          DateTime? now = DateTime.now();
          if (value) {
            var asr =
            DateTime(now.year, now.month, now.day, ps.asr.hour, ps.asr.minute);
            _notificationService.scheduleNotification(
                id: 3,
                title: "ashar",
                body: "ashar",
                scheduledNotificationDateTime: asr);
            print("done set notifi ashar");
            return Tuple2(true, "");
          } else {
            _notificationService.cancelNotifications(3);
            print("done remove notifi ashar");
            return Tuple2(true, "");
          }
        });
      }else{
        return Tuple2(false, "Izinkan Pemberitahuan");
      }
      return Tuple2(true, "");

    });
    return Future.value(result);
  }

  Future<Tuple2<bool, String>> setAdzanMakrib(bool value) async{
    if (this.preferences?.getDouble('_preflatitude') == null) {
      print("errorsss");
      return Tuple2(false, "Aktifkan Lokasi Dahulu");
    }
    // var ps=prayertime();
    var result= await _permission().then((v){
      if (v){
        prayertime().then((ps) {
          DateTime? now = DateTime.now();
          if (value) {
            var maghrib = DateTime(
                now.year, now.month, now.day, ps.maghrib.hour, ps.maghrib.minute);
            _notificationService.scheduleNotification(
                id: 4,
                title: "maghrib",
                body: "maghrib",
                scheduledNotificationDateTime: maghrib);

            print("done set notifi maghrib");
            return Tuple2(true, "");
          } else {
            _notificationService.cancelNotifications(4);
            print("done remove notifi maghrib");
            return Tuple2(true, "");
          }
        });
      }else{
        return Tuple2(false, "Izinkan Pemberitahuan");
      }
      return Tuple2(true, "");

    });
    return Future.value(result);
  }

  Future<Tuple2<bool, String>>  setAdzanIsya(bool value) async{
    if (this.preferences?.getDouble('_preflatitude') == null) {
      print("errorsss");
      return Tuple2(false, "Aktifkan Lokasi Dahulu");
    }
    // var ps=prayertime();
    var result= await _permission().then((v){
      if (v){
        prayertime().then((ps) {
          DateTime? now = DateTime.now();
          if (value) {
            var isha = DateTime(
                now.year, now.month, now.day, ps.isha.hour, ps.isha.minute);
            _notificationService.scheduleNotification(
                id: 5,
                title: "isha",
                body: "isha",
                scheduledNotificationDateTime: isha);

            print("done set notifi isha");
            return Tuple2(true, "");
          } else {
            _notificationService.cancelNotifications(5);
            print("done remove notifi isha");
            return Tuple2(true, "");

          }
        });
      }else{
        return Tuple2(false, "Izinkan Pemberitahuan");
      }
      return Tuple2(true, "");

    });
    return Future.value(result);
  }

  @override
  void initState() {
    super.initState();

    AnalyticsService.observer.analytics
        .setCurrentScreen(screenName: "setting_page");

    initializePreference().whenComplete(() {
      setState(() {
        isSwitchedShubuh =
            this.preferences?.getBool('_isSwitchedShubuh') ?? false;
        isSwitchedzuhur =
            this.preferences?.getBool('_isSwitchedzuhur') ?? false;
        isSwitchedashar =
            this.preferences?.getBool('_isSwitchedashar') ?? false;
        isSwitchedmakrib =
            this.preferences?.getBool('_isSwitchedmakrib') ?? false;
        isSwitchedisya = this.preferences?.getBool('_isSwitchedisya') ?? false;

        _currentAddress = this.preferences?.getString("_prefCurrentAddress");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          centerTitle: true,
          title: Column(children: [
            Text(
              "Pengaturan",
              style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
            ),
          ]),
        ),

        ///A Page View with 3 children
        body: SafeArea(
          child: Column(
            children: [
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Lokasi jadwal sholat',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontStyle: FontStyle.italic)),
                    subtitle: Text(
                      _currentAddress ?? "Lokasi belum di atur",
                      style: TextStyle(fontSize: 17),
                    ),
                    trailing: Icon(Icons.refresh),
                    // trailing: Icon(Icons.arrow_forward),
                  ),
                ),
                onTap: () {
                  showLoaderDialog(context);
                  requestLocation().whenComplete(() {
                    print("okksss");
                    setState(() {
                      _currentAddress =
                          this.preferences?.getString("_prefCurrentAddress");
                      Navigator.pop(context);
                    });
                    // Navigator.of(context).pop();
                  });
                },
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Divider()),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Pemberitahuan Jadwal Sholat',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontStyle: FontStyle.italic)),
                  // subtitle: Text("Tidak ada Pemberitahuan yang aktif"),
                  // trailing: Icon(Icons.arrow_forward),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ListTile(
                  title: Text('Subuh'),
                  trailing: Switch(
                    value: isSwitchedShubuh,
                    onChanged: (value) {
                        setAdzanShubuh(value).then((Tuple2 rr) {
                          if (rr.item1) {
                            setState(() {
                            print('valueee $value');
                            NotifTest();
                            isSwitchedShubuh = value;
                            this.preferences?.setBool(
                                '_isSwitchedShubuh', isSwitchedShubuh);
                            print("done on off shubuh");
                            });
                          } else {
                            showAlert(context, rr.item2);
                          }
                        });

                    },
                    activeTrackColor: Colors.blue,
                    // activeColor: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ListTile(
                  title: Text('Dhuhr'),
                  trailing: Switch(
                    value: isSwitchedzuhur,
                    onChanged: (value) {
                        setAdzanZuhur(value).then((Tuple2 rr) {
                        if (rr.item1) {
                          setState(() {
                          isSwitchedzuhur = value;
                          this
                              .preferences
                              ?.setBool('_isSwitchedzuhur', isSwitchedzuhur);
                          print("done on off Dhuhr");
                          });
                        }else{
                          showAlert(context, rr.item2);
                        }

                        });

                    },
                    activeTrackColor: Colors.blue,
                    // activeColor: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ListTile(
                  title: Text('Ashar'),
                  trailing: Switch(
                    value: isSwitchedashar,
                    onChanged: (value) {
                        setAdzanAshar(value).then((Tuple2 rr) {
                          if (rr.item1){
                            setState(() {
                              isSwitchedashar = value;
                            this
                                .preferences
                                ?.setBool('_isSwitchedashar', isSwitchedashar);

                            print("done on off Ashar");
                            });
                          }else{
                            showAlert(context, rr.item2);
                          }

                        });

                    },
                    activeTrackColor: Colors.blue,
                    // activeColor: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ListTile(
                  title: Text('Magrib'),
                  trailing: Switch(
                    value: isSwitchedmakrib,
                    onChanged: (value) {

                        setAdzanMakrib(value).then((Tuple2 rr) {
                          if(rr.item1){
                            setState(() {
                              isSwitchedmakrib = value;
                            this
                                .preferences
                                ?.setBool('_isSwitchedmakrib', isSwitchedmakrib);

                            print("done on off Magrib");
                            });
                          }else{
                            showAlert(context, rr.item2);
                          }


                        });

                    },
                    activeTrackColor: Colors.blue,
                    // activeColor: Colors.blue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ListTile(
                  title: Text('Isya'),
                  trailing: Switch(
                    value: isSwitchedisya,
                    onChanged: (value) {
                        setAdzanIsya(value).then((Tuple2 rr) {
                          if(rr.item1){
                            setState(() {
                              isSwitchedisya = value;
                            this
                                .preferences
                                ?.setBool('_isSwitchedisya', isSwitchedisya);

                            print("done on off Isya");
                            });
                          }else{
                            showAlert(context, rr.item2);
                          }

                        });

                    },
                    activeTrackColor: Colors.blue,
                    // activeColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _dialogLocationBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pengaturan Lokasi Sholat'),
          content: Row(
            children: [
              Text('Izinkan lokasi terkini'),
              // Container(
              //   height: 10,
              //   child: IconButton(
              //     iconSize:10,
              //     icon: const Icon(Icons.favorite),
              //     onPressed: () {
              //       // ...
              //     },
              //   ),
              // )
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                // if(requestLocation()){
                //   Navigator.of(context).pop();
                // }

                requestLocation().whenComplete(() {
                  print("okksss");
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}

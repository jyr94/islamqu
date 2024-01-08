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
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
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
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _homePage();

}

class _homePage extends State<HomePage> {
  NotificationService _notificationService = NotificationService();
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  SharedPreferences? preferences;
  String? _currentAddress ="";
  Position? _currentPosition;
  String? _nextPrayer;
  String? _nextPrayerName;
  String? _city;
  String? _name;
  Future<List<DailyPrayer>>? dailyPrayer;

  Future<void>initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
    this.preferences?.setString("name", "Peter");
  }
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

      final myCoordinates =
      Coordinates(_currentPosition!.latitude,_currentPosition!.longitude); // Replace with your own location lat, lng.
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      final prayerTimes = PrayerTimes.today(myCoordinates, params);
      
      setState(() {
        _currentAddress =
        '${place.subLocality}, ${place.subAdministrativeArea}';
        _city = '${place.subLocality}';


         // _prefs.setString('_prefCurrentAddress', _currentAddress);
        this.preferences?.setString('_prefCurrentAddress',_currentAddress?? "-");
        this.preferences?.setString('_city', _city ?? "ok");
        this.preferences?.setDouble('_preflatitude', _currentPosition!.latitude);
        this.preferences?.setDouble('_preflongitude', _currentPosition!.longitude);
        _nextPrayerName=prayerTimes.nextPrayer().name;
        DateTime? now = DateTime.now();

        var dhuhr = DateTime(now.year, now.month,  now.day ,prayerTimes.dhuhr.hour,prayerTimes.dhuhr.minute );
        _notificationService.scheduleNotification(
            id: 2,
            title: "dhuhr",
            body: "dhuhr",
            scheduledNotificationDateTime:dhuhr
        );
        var fajr = DateTime(now.year, now.month,  now.day ,prayerTimes.fajr.hour,prayerTimes.fajr.minute );
        _notificationService.scheduleNotification(
            id: 1,
            title: "shubuh",
            body: "shubuh",
            scheduledNotificationDateTime:fajr
        );
        var asr = DateTime(now.year, now.month,  now.day ,prayerTimes.asr.hour,prayerTimes.asr.minute );
        _notificationService.scheduleNotification(
            id: 3,
            title: "ashar",
            body: "ashar",
            scheduledNotificationDateTime:asr
        );

        var maghrib = DateTime(now.year, now.month,  now.day ,prayerTimes.maghrib.hour,prayerTimes.maghrib.minute );
        _notificationService.scheduleNotification(
            id: 4,
            title: "maghrib",
            body: "maghrib",
            scheduledNotificationDateTime:maghrib
        );

        var isha = DateTime(now.year, now.month,  now.day ,prayerTimes.isha.hour,prayerTimes.isha.minute );
        _notificationService.scheduleNotification(
            id: 5,
            title: "isha",
            body: "isha",
            scheduledNotificationDateTime:isha
        );

        switch(_nextPrayerName) {
          case "dhuhr":
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.dhuhr);

            break;
          case "fajr":
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.fajr);


            break;
          case "asr":
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.asr);
            break;
          case "maghrib":
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.maghrib);
            break;
          case "isha":
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.isha);
            break;
          case "sunrise":
            _nextPrayerName="";
            break;
          case "none":
            _nextPrayerName="";
            // _nextPrayer = DateFormat('HH:mm').format(prayerTimes.sunrise);
            break;
          default:
        }
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void _permission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.location.isDenied){
      await Permission.location.request();
    }
    if(await Permission.location.isGranted){
      print("sinisss");
      await _getCurrentPosition();

    }
  }
  @override
  void initState() {
    super.initState();
    // _loadBannerAd();
    print("masukkk page home");
    _permission();
    dailyPrayer=fetchPrayerDaily();
    initializePreference().whenComplete((){
      setState(() {
        print(preferences?.getString("name"));
        print(preferences?.getDouble("_preflatitude"));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    Widget titleSections = Container(
      // color: Colors.red,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child:  Text(
                    '${this.preferences?.getString("_city")}',
                    // '${_currentAddress ?? ""}',
                    // 'test',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
          Center(
            child: Icon(
              Icons.location_on,
              color: Colors.red[500],
            ),
          )
          /*3*/


        ],
      ),
    );

    Widget HeaderSection=Container(
        height: MediaQuery.of(context).size.height * 0.25, // ignore this, cos I am giving height to the container
        width: MediaQuery.of(context).size.width * 0.5, // ignore this, cos I am giving width to the container
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage('https://static.vecteezy.com/system/resources/previews/006/998/428/non_2x/islamic-design-for-background-ramadan-kareem-banner-mosque-silhouette-design-illustration-ramadan-kareem-s-design-is-similar-to-greetings-invitations-templates-or-backgrounds-free-vector.jpg')
            )
        ),
        alignment: Alignment.center, // This aligns the child of the container
        child: Row(
          children: [
            Container(
              // color: Colors.red,
              alignment: Alignment.topCenter,
            child:
            Padding(
              padding: EdgeInsets.only(top: 20.0,left: 20.0), //some spacing to the child from bottom
              child:
                Text('Assalamualaikum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 15))
              ,)
            ),

            Spacer(),
            Container(
              // color: Colors.red,
                alignment: Alignment.bottomLeft,
                child:
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0,right: 20.0), //some spacing to the child from bottom
                  child:
                  Text('${_nextPrayerName ?? ""} :  ${_nextPrayer ?? ""}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                  ,)
            ),


          ],
        )
    );
    Route _createRoute(Widget page) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>  page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }

    Widget MenuSection=Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   // color: Colors.orange,
          //   margin: EdgeInsets.only(left: 20,top: 0),
          //   child: Icon(FlutterIslamicIcons.tasbihHand,size: 50,color: Colors.green[900])
          // ),
          SquareButton(
            icon: Icon(FlutterIslamicIcons.quran2),
            label: 'AlQuran',
            onPressed: (){
              Navigator.of(context).push(_createRoute(DailyPrayerPage()));
            },
          ),
          SquareButton(
            icon: Icon(FlutterIslamicIcons.prayer),
            label: 'Doa',
            onPressed: (){
              Navigator.of(context).push(_createRoute(DailyPrayerPage()));
            },
          ),
          SquareButton(
            icon: Icon(FlutterIslamicIcons.qibla),
            label: 'Qiblat',
            onPressed: (){
              Navigator.of(context).push(_createRoute(Qiblah()));
            },
          ),
          SquareButton(
            icon: Icon(FlutterIslamicIcons.tasbihHand),
            label: 'Tashbih',
            onPressed: (){
              Navigator.of(context).push(_createRoute(DailyPrayerPage()));
            },
          ),
        ],
      ),
    );
    Widget DailyPrayerTitle=Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
       "Doa Harian",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black.withOpacity(0.9),fontSize: 15,fontWeight: FontWeight.bold),
      ),
    );
    Widget timelineTest=FutureBuilder(
        future: dailyPrayer,
        builder: (context, snapshot) {
         if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
            ?
          ListView.separated(
              physics:  NeverScrollableScrollPhysics(),
              controller: _controller,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.requireData.length,
              padding:  const EdgeInsets.all(16.0),
              separatorBuilder: (context,index){
               if ((index + 1) % 4 == 0 && _isBannerAdReady) {
                  return Align(

                     alignment: Alignment.bottomCenter,
                     child: Container(
                       width: _bannerAd.size.width.toDouble(),
                       height: _bannerAd.size.height.toDouble(),
                       // child: AdWidget(ad: _bannerAd),
                       child: AdWidget(ad: _bannerAd),
                     ),
                   );
               }else{
                return Container();
               }
              },
              itemBuilder: (context,index){
               return
                    GestureDetector(
                      child:   Container(
                        // height: 100,
                        child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title:  Text(snapshot.requireData[index].title),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                 snapshot.requireData[index].arab,
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child:
                              Text(
                                snapshot.requireData[index].latin.length > 50 ? snapshot.requireData[index].latin.substring(0, 50)+'  ....' : snapshot.requireData[index].latin,
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            if(snapshot.requireData[index].latin.length < 50)...[
                              Padding(
                                padding: const EdgeInsets.only(left: 16,top: 1,bottom: 1),
                                child: Text(
                                  "artinya",
                                  textAlign: TextAlign.left,

                                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  snapshot.requireData[index].arti,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                            ]else...[
                              Padding(
                                padding: const EdgeInsets.only(left: 16,top: 1,bottom: 5),
                                child: Text(
                                  "Lanjutkan",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      ),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DailyPrayerDetail(dailyPrayer: snapshot.data![index])));
                      },
                    );
              })
            : Center(child: CircularProgressIndicator());
      },
    );



    return Scaffold(
      appBar: AppBar(

        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Islam Qu",
            style: TextStyle(color: Colors.green[900],fontWeight: FontWeight.bold),
          ),
        ),

      ),
        body: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              HeaderSection,
              titleSections,
              MenuSection,
              DailyPrayerTitle,
              timelineTest

            ],
          ),

        ),

    );
  }
}



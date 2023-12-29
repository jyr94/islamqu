import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:islamqu/helper/NotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _homePage();

}

class _homePage extends State<HomePage> {
  NotificationService _notificationService = NotificationService();

  SharedPreferences? preferences;
  String? _currentAddress ="";
  Position? _currentPosition;
  String? _nextPrayer;
  String? _nextPrayerName;
  String? _city;
  String? _name;

  Future<void>initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
    this.preferences?.setString("name", "Peter");
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
    print(position);
    // await placemarkFromCoordinates(
    //     _currentPosition!.latitude, _currentPosition!.longitude)
    //     .then((List<Placemark> placemarks) {
    //   Placemark place = placemarks[0];
      print("calll uy");
      // print(_currentPosition!.latitude);
      final myCoordinates =
      Coordinates(_currentPosition!.latitude,_currentPosition!.longitude); // Replace with your own location lat, lng.
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi;
      final prayerTimes = PrayerTimes.today(myCoordinates, params);
      
      setState(() {
        // _currentAddress =
        // '${place.subLocality}, ${place.subAdministrativeArea}';
        // _city = '${place.subLocality}';


         // _prefs.setString('_prefCurrentAddress', _currentAddress);
        this.preferences?.setString('_prefCurrentAddress',_currentAddress?? "-");
        this.preferences?.setString('_city', _city ?? "ok");
        this.preferences?.setDouble('_preflatitude', _currentPosition!.latitude);
        this.preferences?.setDouble('_preflongitude', _currentPosition!.longitude);
        _nextPrayerName=prayerTimes.nextPrayer().name;
        print(_nextPrayerName);
        switch(_nextPrayerName) {
          case "dhuhr":
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.dhuhr);
            DateTime? now = DateTime.now();
            var dhuhr = DateTime(now.year, now.month,  now.day ,prayerTimes.dhuhr.hour,prayerTimes.dhuhr.minute );
            print(dhuhr);
             _notificationService.scheduleNotification(
                id: 1,
                title: _nextPrayerName,
                body: _nextPrayerName,
                scheduledNotificationDateTime:dhuhr
            );
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
            _nextPrayer = DateFormat('HH:mm').format(prayerTimes.sunrise);
            break;
          case "none":
            _nextPrayerName="";
            // _nextPrayer = DateFormat('HH:mm').format(prayerTimes.sunrise);
            break;
          default:
        }
      });
    // }).catchError((e) {
    //   debugPrint(e);
    // });
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
    print("masukkk page home");
    _permission();
    initializePreference().whenComplete((){
      setState(() {
        print(preferences?.getString("name"));
        print(preferences?.getDouble("_preflatitude"));
      });
    });



  }


  @override
  Widget build(BuildContext context) {
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
                    '${this.preferences?.getDouble("_preflatitude")}',
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

    Widget MenuSection=Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // color: Colors.orange,
            margin: EdgeInsets.only(left: 20,top: 0),
            child: Icon(FlutterIslamicIcons.tasbihHand,size: 50)
          ),
          Container(
            // color: Colors.blue,
            margin: EdgeInsets.all(20.0),
              child: Icon(FlutterIslamicIcons.quran2,size: 50)
          ),
          Container(
            // color: Colors.purple,
            margin: EdgeInsets.all(20.0),
              child: Icon(FlutterIslamicIcons.qibla,size: 50)
          ),
          Container(
            // color: Colors.purple,
            margin: EdgeInsets.all(20.0),
            child: Icon(FlutterIslamicIcons.hadji,size: 50)
          ),
        ],
      ),
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
        body: ListView(
          children: [
            HeaderSection,
            titleSections,
            MenuSection
          ],
        ),

    );
  }
}
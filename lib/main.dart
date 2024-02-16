import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamqu/page/test.dart';
import 'package:islamqu/page/Home.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:islamqu/page/notif.dart';
import 'package:islamqu/helper/NotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:islamqu/page/prayerTime.dart';
import 'package:islamqu/page/qiblah.dart';
import 'package:islamqu/page/daily_prayer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:islamqu/helper/ads.dart';
import 'package:islamqu/helper/analytics.dart';
import 'package:islamqu/page/list_surah.dart';
import 'package:islamqu/page/prayerTime.dart';
import 'package:islamqu/page/setting.dart';
import 'package:islamqu/helper/constant.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  NotificationService().init();
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // adsHelper.init();
  }catch(e) {
    print("ERRRO FIREBASE: $e");
  }

  // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
  // This widget is the root of your application.


}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    print("masukkk");

    super.initState();
    // FirebaseAnalytics.instance.setUserProperty(name: devic);
    //
    // FirebaseAnalytics.instance.logAppOpen();
    AnalyticsService.observer.analytics.setCurrentScreen(screenName: "main");
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.cabinTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
              color:  Colors.white
          )
      ),

      home:  BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}
class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static  List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    PrayerTime(),
    Qiblah(),
    SettingPage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.lantern),
            label: 'test',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.kowtow),
            label: 'Search',
            backgroundColor: Colors.white,
          ),

          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.qibla),
            label: 'Favorite',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.muslim2),
            label: 'Pengaturan',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: unselectColor,
        showSelectedLabels:false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}

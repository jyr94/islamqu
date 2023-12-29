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



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();

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
    LocationPage(),
    NotifPage(),
    PrayerTime(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //
      //   title: Align(
      //     alignment: Alignment.centerLeft,
      //     child: Text(
      //       "Islam Qu",
      //       style: TextStyle(color: Colors.green[900],fontWeight: FontWeight.bold),
      //     ),
      //   ),
      //
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.mosque),
            label: 'test',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.quran2),
            label: 'Search',
            backgroundColor: Colors.white,
          ),

          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.qibla),
            label: 'Favorite',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIslamicIcons.sajadah),
            label: 'Favorite',
            // backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.green,
        showSelectedLabels:false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}

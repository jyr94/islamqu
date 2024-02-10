import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:islamqu/page/loading_indicator.dart';
import 'package:islamqu/page/qiblah_compass.dart';
import 'package:islamqu/page/qiblah_maps.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:islamqu/helper/constant.dart';

class Qiblah extends StatefulWidget {
  Qiblah({Key? key}) : super(key: key);

  @override
  _Qiblah createState() => _Qiblah();
}

class _Qiblah extends State<Qiblah> {

  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(children: [
          Text(
            "Qiblat",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),
          ),
        ]),
      ),
      ///A Page View with 3 children
      body: FutureBuilder(
          future: _deviceSupport,
          builder: (_, AsyncSnapshot<bool?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return LoadingIndicator();
            if (snapshot.hasError)
              return Center(
                child: Text("Error: ${snapshot.error.toString()}"),
              );

            if (snapshot.data!)
              return QiblahCompass();
            else
              return QiblahMaps();
          },
        ),
      );
  }
}
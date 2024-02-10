import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:islamqu/model/prayer.dart';
import 'package:islamqu/helper/analytics.dart';
import 'package:islamqu/helper/constant.dart';
import 'package:google_fonts/google_fonts.dart';
class DailyPrayerDetail extends StatefulWidget{

  const DailyPrayerDetail({Key? key,required this.dailyPrayer}) : super(key: key);
  final DailyPrayer dailyPrayer;

  @override
  State<DailyPrayerDetail> createState() => _dailyPrayerDetail();


}
class _dailyPrayerDetail extends State<DailyPrayerDetail> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.observer.analytics.setCurrentScreen(screenName: "detail_prayer");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(children: [
          Text(
            "Doa Harian",style: TextStyle(color:mainColor,fontWeight: FontWeight.bold),
          ),

        ]),
      ),
      body: SafeArea(
        child:Container(
          // clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title:  Text(this.widget.dailyPrayer.title,style: TextStyle(fontSize: 20),),
                // subtitle: Text(
                //   'Secondary Text',
                //   style: TextStyle(color: Colors.black.withOpacity(0.6)),
                // ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  this.widget.dailyPrayer.arab,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.scheherazadeNew(
                      textStyle:TextStyle(color: Colors.black, fontWeight: FontWeight.normal,fontSize: 20,letterSpacing: 0.0),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                Text(
                  this.widget.dailyPrayer.latin,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ),

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
                    this.widget.dailyPrayer.arti,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:islamqu/api/prayer.dart';
import 'package:islamqu/model/prayer.dart';
import 'package:islamqu/page/dailyPrayerDetail.dart';
import 'package:islamqu/helper/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:islamqu/helper/analytics.dart';
import 'package:islamqu/helper/constant.dart';

class DailyPrayerPage extends StatefulWidget {
  DailyPrayerPage({Key? key}) : super(key: key);
  @override
  _DailyPrayer createState() => _DailyPrayer();
}

class _DailyPrayer extends State<DailyPrayerPage> {
  Future<List<DailyPrayer>>? dailyPrayer;
  TextEditingController editingController = TextEditingController();
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  var items = <DailyPrayer>[];
  var items2 = <DailyPrayer>[];
  void dailyPrayertoList() async{
    var temp=await fetchPrayerDailyAll();
    print(temp.length);
    if (!mounted) return;
    setState(() {
      items=temp;
    });

    items2=temp;
  }
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.adaptiveBannerAdUnitId,
      request: AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
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
  @override
  void initState() {
    // dailyPrayer=fetchPrayerDailyAll();
    // items = dailyPrayer;
    super.initState();
    // _loadBannerAd();
    dailyPrayertoList();
    AnalyticsService.observer.analytics.setCurrentScreen(screenName: "dailyprayer");

  }
  @override
  void dispose() {
    super.dispose();
    // _bannerAd.dispose();
  }

  void filterSearchResults(String query) {
    setState(() {
      items = items2
          .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(children: [
          Text(
            "Doa Harian",style: TextStyle(color: mainColor,fontWeight: FontWeight.bold),
          ),
        ]),
      ),
      ///A Page View with 3 children
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Cari Nama Doa",
                    hintText: "Nama Doa",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.separated(
                    itemCount: items.length,
                    shrinkWrap: true,
                    itemBuilder: (context,index) {
                      return
                        GestureDetector(
                        child: Container(
                          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Card(
                            clipBehavior: Clip.antiAlias,

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text('${items[index].title}'),
                                  // subtitle: Text(
                                  //   'Secondary Text',
                                  //   style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                  // ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '${items[index].arab}',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child:
                                  Text(items[index].latin.length > 50 ? '${items[index].latin.substring(0, 50)}' + '  ....'
                                        :  '${items[index].latin}',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                if(items[index].latin.length < 50)...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 1, bottom: 1),
                                    child: Text(
                                      "artinya",
                                      textAlign: TextAlign.left,

                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      '${items[index].latin}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ),
                                ] else
                                  ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, top: 1, bottom: 5),
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
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) =>
                                  DailyPrayerDetail(dailyPrayer: items[index])));
                        },
                      );
                    },
                separatorBuilder: (context,index){
                  if (index== 4 && _isBannerAdReady) {
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
                    ),
            ),
          ],
        ),
      )

    );
  }
}
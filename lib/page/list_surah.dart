import 'package:flutter/material.dart';
import 'package:islamqu/api/prayer.dart';
import 'package:islamqu/model/prayer.dart';
import 'package:islamqu/page/dailyPrayerDetail.dart';
import 'package:islamqu/helper/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamqu/api/surah.dart';
import 'package:islamqu/model/surah.dart';
import 'package:islamqu/page/read_alquran.dart';
import 'package:islamqu/helper/analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamqu/helper/constant.dart';


class ListSurahPage extends StatefulWidget {
  ListSurahPage({Key? key}) : super(key: key);
  @override
  _ListSurahPage createState() => _ListSurahPage();
}

class _ListSurahPage extends State<ListSurahPage> {
  Future<List<AllSurah>>? allSurah;
  TextEditingController editingController = TextEditingController();
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  SharedPreferences? preferences;
  late int? _bookmarkAyat=0;
  late int? _bookmarkSurah;
  late String? _bookmarkSurahName;
  late String? _bookmarkSuraharab;
  late int? num=0;
  AllSurah? bookmark;
  var items = <AllSurah>[];
  var items2 = <AllSurah>[];
  void allSurahToList() async{
    var temp=await readJsonAllSurah();
    print(temp.length);
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
  Future<void>initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }
  void refreshbookmark(){
    setState(() {
      _bookmarkAyat=preferences?.getInt("_bookmarkAyat");
      _bookmarkSurah=preferences?.getInt("_bookmarkSurah");
      _bookmarkSurahName=preferences?.getString('_bookmarkSurahName');
      _bookmarkSuraharab=preferences?.getString('_bookmarkSuraArab');
      // bookmark.id=_bookmarkSurah!;
      // bookmark.name=_bookmarkSurahName!;
      // bookmark.textArab=_bookmarkSuraharab!;
      if(_bookmarkSurah!=null){
        bookmark=new AllSurah(id: _bookmarkSurah!, name: _bookmarkSurahName!, textArab: _bookmarkSuraharab!, terjemahan: "", countAyat: 0);
      }

    });
   print("jerii");
  }

  @override
  void initState() {
    // dailyPrayer=fetchPrayerDailyAll();
    // items = dailyPrayer;
    super.initState();
    // bookmark=new AllSurah()
    // _loadBannerAd();
    print("call iniit state");
    allSurahToList();
    _bookmarkSurah=null;
    AnalyticsService.observer.analytics.setCurrentScreen(screenName: "list_surah");
    initializePreference().whenComplete((){
      setState(() {
        refreshbookmark();
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
    // _bannerAd.dispose();
  }

  void filterSearchResults(String query) {
    setState(() {
      items = items2
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(AllSurah model) => ListTile(
      contentPadding:
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: new BoxDecoration(
            border: new Border(
                right: new BorderSide(width: 1.0, color: Colors.white24))),
        child: Stack(
            children: [
              Image.asset(
                "assets/brsurah.png",
                height: 50, // device or widget height
                width: 50, // device or widget height
                // centerSlice: const Rect.fromLTRB(115, 115, 358, 555),
              ), // your border image
              Container(
                // color: Colors.red,
                height: 40,
                width: 40,
                margin: EdgeInsets.only(left: 6,top: 4),
                child:Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${model.id}'' ',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold,fontSize: 20),),
                ),

              ) // other widgets inside border
            ]
        )
        // Text(
        //     '${model.id}''. ',
        //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 15),),
      ),
      title: Text(
        model.name,
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

      subtitle: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Container(
                // tag: 'hero',
                child: Text(model.textArab,
                    style: TextStyle(color: Colors.black87,fontSize: 20)),
              )),
        ],
      ),
      // trailing:
      // Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReadQuranPage(surah:model,callback: refreshbookmark)));
      },
    );

    Card makeCard(AllSurah allSurah) => Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white70,
        borderRadius: BorderRadius.circular(5)),
        child: makeListTile(allSurah),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Column(children: [
            Text(
              "Al Quran",style: TextStyle(color:mainColor,fontWeight: FontWeight.bold),
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
                      labelText: "Cari Nama Surah",
                      hintText: "Nama Surah",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              if(_bookmarkSurah!=null)...[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child:  ListTile(
                      leading: Icon(Icons.bookmark),
                      title: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                // tag: 'hero',
                                child:   Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Container(
                                      // tag: 'hero',
                                      child: Text('${_bookmarkSurahName}',
                                          style: TextStyle(color: Colors.black,fontSize: 15,fontStyle: FontStyle.italic)),
                                    ),
                                    Container(
                                      // tag: 'hero',
                                      child: Text('${_bookmarkSuraharab}',
                                          style: TextStyle(color: Colors.black45,fontSize: 15)),
                                    ),

                                  ],
                                ),
                              )),
                        ],
                      ),
                      subtitle: Text("terakhir dibaca ayat ${_bookmarkAyat!!+1}"),
                      trailing: Icon(Icons.arrow_forward),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReadQuranPage(surah:this.bookmark!,callback: refreshbookmark,bookmarkPosition: _bookmarkAyat!,)));
                  },
                )

              ],

              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: (context,index) {
                    return makeCard(items[index]);

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

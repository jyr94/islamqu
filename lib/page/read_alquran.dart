import 'package:flutter/material.dart';
import 'package:islamqu/api/prayer.dart';
import 'package:islamqu/model/prayer.dart';
import 'package:islamqu/page/dailyPrayerDetail.dart';
import 'package:islamqu/helper/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamqu/api/surah.dart';
import 'package:islamqu/model/surah.dart';
// import 'package:arabic_font/arabic_font.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:islamqu/helper/analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamqu/page/list_surah.dart';

class ReadQuranPage extends StatefulWidget {
  ReadQuranPage({Key? key,required this.surah,required this.callback}) : super(key: key);
  final AllSurah surah;
  final Function callback;
  @override
  _ReadQuranPage createState() => _ReadQuranPage();
}

class _ReadQuranPage extends State<ReadQuranPage> {
  Future<List<DetailAyat>>? detailAyat;
  TextEditingController editingController = TextEditingController();
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  bool _isLoading=false;
  // ScrollController _controller= new ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  SharedPreferences? preferences;


  var items = <DetailAyat>[];
  var items2 = <DetailAyat>[];
  late int? _bookmarkAyat;
  late int? _bookmarkSurah;

  Future<void>initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }

  bool bookmarkSurah(int index){
    this.preferences?.setInt('_bookmarkAyat', index);
    this.preferences?.setInt('_bookmarkSurah', this.widget.surah.id);
    this.preferences?.setString('_bookmarkSurahName', this.widget.surah.name);
    this.preferences?.setString('_bookmarkSuraArab', this.widget.surah.textArab);
    setState(() {
      _bookmarkAyat=preferences?.getInt("_bookmarkAyat");
      _bookmarkSurah=preferences?.getInt("_bookmarkSurah");
    });
    this.widget.callback();
    print("success bookmark");

    return true;
  }

  bool removebookmarkSurah(int index){
    this.preferences?.remove('_bookmarkAyat');
    this.preferences?.remove('_bookmarkSurah');
    this.preferences?.remove('_bookmarkSurahName');
    this.preferences?.remove('_bookmarkSuraArab');
    setState(() {
      _bookmarkAyat=preferences?.getInt("_bookmarkAyat");
      _bookmarkSurah=preferences?.getInt("_bookmarkSurah");
    });
    print("successremove bookmark");
    this.widget.callback();
    return true;
  }

  void allSurahToList() async{

    _isLoading=true;
    var surahID=this.widget.surah.id.toString();
    var temp=await readJsonSurah(surahID);
    // await Future.delayed(const Duration(seconds: 3), (){});
    setState(() {
      _isLoading=false;
      items=temp;
    });
    print(items[6].arabic);
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
  _ScrollPosition() async {
    // print( _controller.offset);
  }

  @override
  void initState() {
    // dailyPrayer=fetchPrayerDailyAll();
    // items = dailyPrayer;
    // _controller.jumpTo(100.0);
    super.initState();
    // _loadBannerAd();
    allSurahToList();
    AnalyticsService.observer.analytics.setCurrentScreen(screenName: "read_quran");
    // itemScrollController.jumpTo(index: 10);
    initializePreference().whenComplete((){
      setState(() {
        _bookmarkAyat=preferences?.getInt("_bookmarkAyat");
        _bookmarkSurah=preferences?.getInt("_bookmarkSurah");
        print("bookmark save");
        print(_bookmarkAyat);
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
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    ListTile makeListTile(DetailAyat ayat,int index) => ListTile(
      contentPadding:
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.0),
      title: RichText(
        textAlign: TextAlign.right,

        text: TextSpan(
            text: ayat.arabic,
            style: GoogleFonts.scheherazadeNew(
                textStyle:TextStyle(color: Colors.black, fontWeight: FontWeight.normal,fontSize: 30,letterSpacing: 0.0)
            ),

        ),
      ),
      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
      //
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
            // tag: 'hero',
            child: Text('${ayat.ayah.toString()}. ${ayat.latin}',
                style: TextStyle(color: Colors.black,fontSize: 15,fontStyle: FontStyle.italic)),
          ),
          Container(
            // tag: 'hero',
            child: Text(ayat.translation,
                style: TextStyle(color: Colors.black45,fontSize: 15)),
          ),
          // if(index==1)...[
          if (_bookmarkAyat==index && _bookmarkSurah==this.widget.surah.id)...[
            GestureDetector(
              child: Container(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.bookmark_remove_outlined,
                  color: Colors.green,
                ),
              ),
              onTap: (){
                print("ontap");
                var result =removebookmarkSurah(index);
                if (result){
                  AlertDialog alert = AlertDialog(
                    title: Text('Succcess remove bookmark'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return alert;
                      }
                  );
                }
              },
            )
          ]else...[
            GestureDetector(
              child: Container(
                // color: Colors.red,
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.bookmark_add_outlined,
                ),
              ),
              onTap: (){
               var result= bookmarkSurah(index);
                if (result){
                  AlertDialog alert = AlertDialog(
                    title: Text('Succcess bookmark'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return alert;
                      }
                  );
                }

              },
            )
          ]


        ],
      ),
      // trailing:
      // Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        // print(index);
      },
    );

    Card makeCard(DetailAyat ayat,int index) => Card(
      elevation: 1.0,
      margin: new EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
      child:
      Container(
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(1)
        ),
        child: makeListTile(ayat,index),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          
          // automaticallyImplyLeading: false,
          centerTitle: true,
          title: Column(children: [
            Text(
              this.widget.surah.name,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20),)
            // Stack(
            //     children: [
                  // Image.asset(
                  //   "assets/titleborderblack.png",
                  //   fit: BoxFit.fill,
                  //   height: 70, // device or widget height
                  //   width: 250, // device or widget height
                  //   // centerSlice: const Rect.fromLTRB(1, 1, 2, 1),
                  // ), // your border image

                  // Container(
                  //   // color: Colors.red,
                  //   // margin: EdgeInsets.only(left: 0,top: 10),
                  //   child:Align(
                  //     alignment: Alignment.center,
                  //     child: Text(
                  //       this.widget.surah.name,
                  //       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20),),
                  //   ),
                  //
                  // ) // other widgets inside border
            //     ]
            // ),
          ]),
        ),
        ///A Page View with 3 children
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,//Center Column contents vertically,
                  crossAxisAlignment: CrossAxisAlignment.center ,//Center Column contents horizontally,
                  children: [
                    // Flexible(flex: 1, child: Container(color: Colors.blue)),
                    Flexible(flex: 2,
                        child: Container(
                      child: Text(
                      this.widget.surah.textArab,
                        style: GoogleFonts.scheherazadeNew(
                        textStyle:TextStyle(color: Colors.black, fontWeight: FontWeight.normal,fontSize: 20,letterSpacing: 0.0)
                    ),
                    ),)),
                    Flexible(flex: 2, child: Container(child: Text(
                      this.widget.surah.terjemahan,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15,fontStyle: FontStyle.italic),
                    ),)),
                  ],
                ),
              ),



              _isLoading?  Container(child:
              Center(
                heightFactor: 5,
                child: CircularProgressIndicator(),
              )): Container(),
              Expanded(
                child: ScrollablePositionedList.builder(
                  // reverse: true,
                  // controller: _controller,
                  itemScrollController: itemScrollController,
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context,index) {
                    return makeCard(items[index],index);
                    // return Text(items[index].latin);

                  },
                  // separatorBuilder: (context,index){
                  //   if (index== 4 && _isBannerAdReady) {
                  //     return Align(
                  //       alignment: Alignment.bottomCenter,
                  //       child: Container(
                  //         width: _bannerAd.size.width.toDouble(),
                  //         height: _bannerAd.size.height.toDouble(),
                  //         // child: AdWidget(ad: _bannerAd),
                  //         child: AdWidget(ad: _bannerAd),
                  //       ),
                  //     );
                  //   }else{
                  //     return Container();
                  //   }
                  // },
                ),
              ),


            ],
          ),
        )

    );
  }
}

class DailyPrayer {
  // final List<String>? tag;
   String title;
   String arab;
   String latin;
   String arti;
   String footnote;

  DailyPrayer({
    required this.title,
    required this.arab,
    required this.latin,required this.arti,required this.footnote
   });

  factory DailyPrayer.fromJson(Map<String, dynamic> json) => DailyPrayer(
    // tag: json["tag"],
    title: json["judul"],
    arab: json["arab"],
    latin: json["latin"],
    arti: json["arti"],
    footnote: json["footnote"]
  );


}
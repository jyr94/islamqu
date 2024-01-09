
class AllSurah {
  // final List<String>? tag;
  int id;
  String name;
  String textArab;
  String terjemahan;
  int countAyat;

  AllSurah({
    required this.id,
    required this.name,
    required this.textArab,
    required this.terjemahan,
    required this.countAyat
  });

  factory AllSurah.fromJson(Map<String, dynamic> json) => AllSurah(
    // tag: json["tag"],
      id: json["id"],
      name: json["surat_name"],
      textArab: json["surat_text"],
      terjemahan: json["surat_terjemahan"],
      countAyat: json["count_ayat"]
  );


}
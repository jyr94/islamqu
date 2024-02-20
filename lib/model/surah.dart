
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
      id: json["id"],
      name: json["surat_name"],
      textArab: json["surat_text"],
      terjemahan: json["surat_terjemahan"],
      countAyat: json["count_ayat"]
  );
}
class DetailAyat{
  int id;
  int surahId;
  int ayah;
  int juz;
  String arabic;
  String latin;
  String translation;

  DetailAyat({
    required this.id,
    required this.ayah,
    required this.juz,
    required this.surahId,
    required this.latin,
    required this.arabic,
    required this.translation,
  });

  factory DetailAyat.fromJson(Map<String, dynamic> json)=>DetailAyat(
    id: json["id"],
    surahId: json["surah_id"],
    ayah: json["ayah"],
    juz: json["juz"],
    arabic: json["arabic"],
    latin: json["latin"],
    translation: json["translation"]
  );
}


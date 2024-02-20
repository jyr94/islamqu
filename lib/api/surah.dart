import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:islamqu/model/surah.dart';

Future<List<AllSurah>> readJsonAllSurah() async {
  final String response = await rootBundle.loadString('assets/surah/surah.json');
  final datas = await json.decode(response);
  return datas["data"].map<AllSurah>((json) =>AllSurah.fromJson(json)).toList();

}
Future<List<DetailAyat>> readJsonSurah(String surah) async {
  final String url='assets/surah/${surah}.json';
  final String response = await rootBundle.loadString(url);
  // print(url);
  final datas = await json.decode(response);
  // print(datas);
  return datas.map<DetailAyat>((json) =>DetailAyat.fromJson(json)).toList();

}
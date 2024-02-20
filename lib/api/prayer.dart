import 'dart:io';

import 'package:islamqu/model/prayer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';




Future<List<DailyPrayer>> fetchPrayerDaily() async {
  final response = await http.get(Uri.parse("https://gist.githubusercontent.com/jeri06/5fc3f5e482e7f53f8dfec907e5c047d8/raw/ae160ff7f3092564240194d6695ae9e6df3c03a7/json")
  );

  if (response.statusCode == 200) {
    Random random = new Random();
    // print("oks");
    // print(decodeDailyPrayer(response.body));
    List<DailyPrayer> datas=[];
    List<DailyPrayer> limit=decodeDailyPrayer(response.body);
    for (var i = 0; i < 5; i++) {
      datas.add(limit[random.nextInt(16)]);
    }
    return datas;
  } else {
    throw Exception('Unable to fetch data from the REST API');
  }
  // return null
}
Future<List<DailyPrayer>> fetchPrayerDailyAll() async {
  final response = await http.get(Uri.parse("https://gist.githubusercontent.com/jeri06/5fc3f5e482e7f53f8dfec907e5c047d8/raw/ae160ff7f3092564240194d6695ae9e6df3c03a7/json")
  );

  if (response.statusCode == 200) {
    return decodeDailyPrayer(response.body);
  } else {
    throw Exception('Unable to fetch data from the REST API');
  }
  // return null
}
List<DailyPrayer> decodeDailyPrayer(String responseBody) {
  // print(json.decode(responseBody).cast<Map<String, dynamic>>().);
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  // print(parsed);
  return parsed.map<DailyPrayer>((json) => DailyPrayer.fromJson(json)).toList();
}
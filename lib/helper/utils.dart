import 'dart:convert';

String dateFormatter(DateTime date) {
  dynamic dayData =
      '{ "1" : "Senin", "2" : "Selasa", "3" : "Rabu", "4" : "Kamis", "5" : "Jumat", "6" : "Sabtu", "7" : "Minggu" }';

  dynamic monthData =
      '{ "1" : "Jan", "2" : "Feb", "3" : "Mar", "4" : "Apr", "5" : "May", "6" : "June", "7" : "Jul", "8" : "Aug", "9" : "Sep", "10" : "Oct", "11" : "Nov", "12" : "Dec" }';

  return json.decode(dayData)['${date.weekday}'] +
      ", " +
      date.day.toString() +
      " " +
      json.decode(monthData)['${date.month}'] +
      " " +
      date.year.toString();
}

String reformatInt(int value){
  String nol='0';

  int length = value.toString().length; // 7
  if (length==1){
    return '$nol$value'.toString();
  }
  return value.toString();
}

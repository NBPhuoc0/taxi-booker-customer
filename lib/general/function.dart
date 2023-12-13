import 'dart:math';

import 'package:latlong2/latlong.dart';



String latlngReverseToString(LatLng value) {
  return "${value.longitude},${value.latitude}";
}

String convertToURIPart(String value) {
  return value.replaceAll(" ", "%20");
}



// * Tính quãng đường và thời gian giữa 2 vị trí
int getWayDistance(List<LatLng> latlngList) {

  // Công thức Haversine

  double d = 0.0;
  for (int i = 0; i < latlngList.length - 1; i++) {

    double lat1 = latlngList[i].latitudeInRad;
    double lng1 = latlngList[i].longitudeInRad;
    double lat2 = latlngList[i + 1].latitudeInRad;
    double lng2 = latlngList[i + 1].longitudeInRad;

    double left = sin((lat2 - lat1) / 2) * sin((lat2 - lat1) / 2);
    double middle = cos(lat1) * cos(lat2);
    double right = sin((lng2 - lng1) / 2) * sin((lng2 - lng1) / 2);

    d += asin(sqrt(left + middle * right));
  }

  return (d * 2000 * 6371).toInt();
}


int getBirdDistance(LatLng pickupLatLng, LatLng dropoffLatLng) {
  double lat1 = pickupLatLng.latitudeInRad;
  double lng1 = pickupLatLng.longitudeInRad;
  double lat2 = dropoffLatLng.latitudeInRad;
  double lng2 = dropoffLatLng.longitudeInRad;

  double left = sin((lat2 - lat1) / 2) * sin((lat2 - lat1) / 2);
  double middle = cos(lat1) * cos(lat2);
  double right = sin((lng2 - lng1) / 2) * sin((lng2 - lng1) / 2);

  double d = asin(sqrt(left + middle * right));

  return (d * 2000 * 6371).toInt();
}


int getDuration(int distance, { bool goodHour = false }) {
  // Vận tốc trung bình: 6.6 m/s (trong điều kiện bình thường)
  double velocity = goodHour ? 6.6 : 4.5;
  return distance ~/ velocity;
}


double getDescrateDistanceSquare(LatLng first, LatLng second) {
  double byX = first.latitude - second.latitude;
  double byY = first.longitude - second.longitude;
  byX *= byX;
  byY *= byY;
  return byX + byY;
  // return sqrt(byX + byY);  // Không cần căn bậc hai
}

String formatPhonenumber(String phonenumber, bool lengthening, { String country = "VN" }) {

  if (phonenumber.length < 11) {
    return "";
  }
  else if (!lengthening) {
    return phonenumber.substring(4);
  }
  else {
    switch (country) {
      case "VN": return "+84 $phonenumber";
      default: return "[ERROR]";
    }
  }
}



int getPrice(int distance, int vehicleType, { bool goodHour = false, bool goodWeather = false }) {
  // 1000 l ~ 50000 m  ~ 300.000 vnđ
  //          distance ~ ...?
  double price = distance * 6.0;
  switch (vehicleType) {
    case 0: return 0;
    case 1: price *= 1.1;
    case 2: price *= 1.4;
    case 3: price *= 1.6;
  }

  if (!goodHour) {
    price *= goodWeather ? 1.2 : 1.5;
  }
  return price.toInt();
}



String durationToString(int duration) {
  if (duration > 3600) {
    return "${(duration ~/ 60 ~/ 3 / 20).toString()} giờ";
  }
  else {
    return "${(duration  ~/ 60).toString()} phút";
  }
}



String distanceToString(int distance) {
  if (distance > 1000) {
    return "${(distance ~/ 100 / 10).toString()} km";
  }
  else {
    return "${distance.toString()} m";
  }
}



String formatHour(DateTime datetime) {
  return "${datetime.hour} : ${datetime.minute}";
}


String readDateTime(value) {
  DateTime read;
  try { read = DateTime.parse(value); }
  catch (e) { read = DateTime.now(); }
  return "${read.day} / ${read.month} / ${read.year}";
}


String readHour(value) {
  String result = "";
  if (value.hour < 10) {
    result += "0";
  }
  result += "${value.hour} : ";
  if (value.minute < 10) {
    result += "0";
  }
  result = "${value.minute}";
  return result;
}



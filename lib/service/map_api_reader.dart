import "dart:convert";
import "dart:developer" as developer;

import "package:flutter/material.dart";

// import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:http/http.dart" as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import "package:location_picker_flutter_map/location_picker_flutter_map.dart";

import '/general/constant.dart';
import "/general/function.dart";

import '/service/account_reader.dart';


class MapAPIReader extends AccountReader {

  // * Gửi toạ độ
  // *
  // * RETURN: <bool>
  // *
  // Future<bool> setPickupLatLong(LatLng value, String token, { bool callExpired = false }) async {
  //   developer.log("Update latitude and longitude of MapAPIReader");
  //   final response = await http.patch(Uri.parse(Customer.setLatLong),
  //                                     headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer "+ token },
  //                                     body: { "latitude": value.latitude, "longitude": value.longitude });
    
  //   switch (response.statusCode) {
  //     case 200: case 201:
  //       return Future.value(true);
      
  //     case 401:
  //       if (!callExpired) {
  //         await AccountReader().getNewTokens(token);
  //         return await setPickupLatLong(value, await TokenSaver().loadRefreshToken(), callExpired: true);
  //       }
  //       else {
  //         developer.log("Failed HTTP when update at setPickupLatLong(): ${response.statusCode}");
  //         return Future.value(false);
  //       }
      
  //     default:
  //       developer.log("Failed HTTP when update at setPickupLatLong(): ${response.statusCode}");
  //       return Future.value(false);
  //   }
  // }



  // * -------------------- Cập nhật vị trí địa chỉ bắt đầu --------------------
  // *
  // * RETURN: {
  // *   status: <bool>
  // *   body: <String>
  // * }
  // *
  Future< Map<String, dynamic> > getAddr(LatLng latlng) async {

    Map<String, dynamic> result = { "status": true };

    developer.log("Call Nominatim API. Run `getAddr($latlng)`.");
    final response = await http.get(Uri.parse(
      "$locationWeb/reverse?format=json&lat=${latlng.latitude}&lon=${latlng.longitude}&zoom=18&addressdetails=1"));

    try {
      if (response.statusCode == 200) {
        result["body"] = json.decode(utf8.decode(response.bodyBytes))["display_name"];
      }
      else {
        developer.log("Failed HTTP when reading map at getPickupAddr(): ${response.statusCode}");
        result["status"] = false;
      }
      return result;
    }
    catch (e) { throw Exception("Failed code when getting pickup address, at map_api_reader.dart. Error type: ${e.toString()}"); }
  }



  // * -------------------- Cập nhật vị trí toạ độ cần đến --------------------
  // *
  // * RETURN: {
  // *   status: <bool>
  // *   body: <PickedData> { LatLong, String, Map }
  // * }
  // *
  Future< Map<String, dynamic> > getPickedData(String text) async {

    Map<String, dynamic> result = { "status": true };

    developer.log("Call OpenRouteService API. Run `getPickedData($text)`.");
    final response = await http.get(Uri.parse("$web/$searchGeocoding?api_key=$key&text=${convertToURIPart(text)}&boundary.country=VN&size=1"));
    
    try {
      if (response.statusCode == 200) {
        final jsonVal = json.decode(utf8.decode(response.bodyBytes));
        final coords = jsonVal["features"][0]["geometry"]["coordinates"];

        PickedData body = PickedData(LatLong(coords[1], coords[0]), jsonVal["features"][0]["properties"]["label"], {});
        result["body"] = body;
      }
      else {
        developer.log("Failed HTTP when reading map at getPickedData(): ${response.statusCode}");
        result["status"] = false;
      }
      return result;
    }
    catch (e) { throw Exception("Failed code when getting PickedData, at map_api_reader.dart. Error type: ${e.toString()}"); }
  }




  // * -------------------- Tìm đường giữa điểm bắt đầu và kết thúc --------------------
  // *
  // * RETURN: {
  // *   status: <bool>
  // *   polyline: <Polyline>,
  // *   distance: <int>,
  // *   duration: <int>
  // * }
  // *
  Future< Map<String, dynamic> > getPolyline(LatLng origin, LatLng destination, Color color, { bool quick = false }) async {
    developer.log("Call OpenRouteService API. Run `getPolyline()`. Data: start = $origin, end = $destination");

    Map<String, dynamic> result = { "status": true };

    final response = await http.get(Uri.parse(
      "$web/$directionsService?api_key=$key&start=${latlngReverseToString(origin)}&end=${latlngReverseToString(destination)}"));

    try {
      if (response.statusCode == 200) {
        final jsonVal = json.decode(utf8.decode(response.bodyBytes));
        final readingJson = jsonVal["features"][0]["geometry"]["coordinates"];
        final readingList = readingJson.map<LatLng>((e) => LatLng(e[1], e[0]))
                                        .toList();
        
        result["polyline"] = Polyline(points: readingList, color: color, strokeWidth: 3);
        if (!quick) {

          bool goodWeather = false;
          bool goodHour = false;

          // Đọc thời tiết
          final weatherStatus = await getCurrentWeather(origin);
          if (weatherStatus["status"]) {
            // "Clear"  |  "Clouds"  |  "Rain"  |  "Snow"  |  "Drizzle"  |  "Thunderstorm"  |  "Mist"
            switch (weatherStatus["body"]) {
              case "Clear": case "Clouds": goodWeather = true; break;
              default: goodWeather = false; break;
            }
          }

          final datetime = DateTime.now().toLocal();
          goodHour = ! ( (datetime.hour >= 23) || (datetime.hour <= 7) || ((datetime.hour >= 16) && (datetime.hour <= 18)) );

          developer.log("The weather today is ${ goodWeather ? "good" : "bad" }.");
          developer.log("The traffic today is ${ goodHour ? "good" : "bad" }.");

          result["distance"] = getWayDistance(readingList);
          result["duration"] = getDuration(result["distance"], goodHour: goodHour);
          result["good_weather"] = goodWeather;
          result["good_hour"] = goodHour;
        }
      }
      else {
        developer.log("Failed HTTP when reading map at getPolyline(): ${response.statusCode}");
        result["status"] = false;
      }
      return result;
    }
    catch (e) { throw Exception("Failed code when getting polylines, at map_api_reader.dart. Error type: ${e.toString()}"); }
  }



  // * -------------------- Lấy trạng thái thời tiết hiện tại -------------------- 
  // *
  // * RETURN: {
  // *   status: <bool>
  // *   body: <String>
  // * }
  // *
  Future< Map<String, dynamic> > getCurrentWeather(LatLng position) async {
    developer.log("Call OpenWeatherMap API. Run `getCurrentWeather()`. Data: LatLng = $position");

    Map<String, dynamic> result = { "status": true };

    final response = await http.get(Uri.parse(
      "$weatherWeb/$oneCall?lat=${position.latitude}&lon=${position.longitude}&appid=$weatherKey"));


    try {
      if (response.statusCode == 200) {
        final jsonVal = json.decode(response.body);
        result["body"] = jsonVal["current"]["weather"][0]["main"];
      }
      else {
        developer.log("Failed HTTP when reading weather(): ${response.statusCode}. Link: $weatherWeb/$oneCall?lat=${position.latitude}&lon=${position.longitude}&appid=$weatherKey");
        result["status"] = false;
      }
      return result;
    }
    catch (e) { throw Exception("Failed code when getting weather, at map_api_reader.dart. Error type: ${e.toString()}"); }
  }
}
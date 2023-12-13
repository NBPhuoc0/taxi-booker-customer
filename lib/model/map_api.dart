import "dart:developer" as developer;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';





class MapAPI {

  String tripId = "";

  String pickupAddr = "";
  LatLng pickupLatLng = const LatLng(10.0, 100.0);

  String dropoffAddr = "";
  LatLng dropoffLatLng = const LatLng(10.0, 100.0);

  LatLng driverLatLng = const LatLng(10.0, 100.0);

  int price = 0;      // Đơn vị: VNĐ
  int distance = 0;   // Đơn vị: mét
  int duration = 0;   // Đơn vị: giây

  bool goodWeather = true;
  bool goodHour = true;
  DateTime bookingTime = DateTime.now();

  Polyline s2ePolylines = Polyline(points: []);
  Polyline d2sPolylines = Polyline(points: []);

  String driverId = "";
  String driverName = "";
  String driverPhonenumber = "";



  // * Tạm lưu
  Future saveCustomer() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("map_API_tripId",         tripId);

    await sp.setString("map_API_pickupAddress",  pickupAddr);
    await sp.setDouble("map_API_pickupLat",      pickupLatLng.latitude);
    await sp.setDouble("map_API_pickupLng",      pickupLatLng.longitude);
    await sp.setString("map_API_dropoffAddress", dropoffAddr);
    await sp.setDouble("map_API_dropoffLat",     dropoffLatLng.latitude);
    await sp.setDouble("map_API_dropoffLng",     dropoffLatLng.longitude);

    await sp.setInt("map_API_price", price);
    await sp.setInt("map_API_distance", distance);
    await sp.setInt("map_API_duration", duration);
    await sp.setString("map_API_bookingTime", bookingTime.toString());
  }


  Future saveDriver() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("map_API_driverId",    driverId);
    await sp.setString("map_API_driverName",  driverName);
    await sp.setString("map_API_driverPhone", driverPhonenumber);
    await sp.setDouble("map_API_driverLat",   driverLatLng.latitude);
    await sp.setDouble("map_API_driverLng",   driverLatLng.longitude);
  }



  // * Lấy dữ liệu
  Future loadCustomer() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    tripId        = sp.getString("map_API_tripId") ?? "";
    pickupAddr    = sp.getString("map_API_pickupAddress") ?? "";
    pickupLatLng  = LatLng(sp.getDouble("map_API_pickupLat") ?? 0, sp.getDouble("map_API_pickupLng") ?? 0);
    dropoffAddr   = sp.getString("map_API_dropoffAddress") ?? "";
    dropoffLatLng = LatLng(sp.getDouble("map_API_dropoffLat") ?? 0, sp.getDouble("map_API_dropoffLng") ?? 0);
    
    price    = sp.getInt("map_API_price")    ?? 0;
    distance = sp.getInt("map_API_distance") ?? 0;
    duration = sp.getInt("map_API_duration") ?? 0;
    try { bookingTime = DateTime.parse(sp.getString("map_API_bookingTime")!); }
    catch (e) { bookingTime = DateTime.now(); }
  }


  Future loadDriver() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    driverId          = sp.getString("map_API_driverId")    ?? "";
    driverName        = sp.getString("map_API_driverName")  ?? "";
    driverPhonenumber = sp.getString("map_API_driverPhone") ?? "";
    driverLatLng = LatLng(sp.getDouble("map_API_driverLat") ?? 0, sp.getDouble("map_API_driverLng") ?? 0);
  }


  Future<DateTime> loadBookingTime() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      bookingTime = DateTime.parse(sp.getString("map_API_bookingTime")!);
    }
    catch (e) { developer.log("Throw error `loadBookingTime()`. Exception: $e"); }
    return bookingTime;
  }




  // * Xoá
  Future<bool> clearData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("map_API_tripId",         "");

    await sp.setString("map_API_pickupAddress",  "");
    await sp.setDouble("map_API_pickupLat",      0.0);
    await sp.setDouble("map_API_pickupLng",      0.0);
    await sp.setString("map_API_dropoffAddress", "");
    await sp.setDouble("map_API_dropoffLat",     0.0);
    await sp.setDouble("map_API_dropoffLng",     0.0);

    await sp.setInt("map_API_price", 0);
    await sp.setInt("map_API_distance", 0);
    await sp.setInt("map_API_duration", 0);
    await sp.setString("map_API_bookingTime", DateTime.now().toString());

    await sp.setString("map_API_driverId",    "");
    await sp.setString("map_API_driverName",  "");
    await sp.setString("map_API_driverPhone", "");
    await sp.setDouble("map_API_driverLat",   0.0);
    await sp.setDouble("map_API_driverLng",   0.0);

    return Future.value(true);
  }




// //   GoogleMapPolyline? googleMapPolyline;

//   // --------------------  Lấy danh sách các gợi ý -------------------- 

//   // Future< List<String> > getHintLocations(String input) async {

//   //   List<String> locationDescription = [];
//   //   var response = await http.get(Uri.https("maps.googleapis.com",
//   //                                           "maps/api/place/autocomplete/json",
//   //                                           { "input": input, "key": key }));
//   //   try {
//   //     if (response.statusCode == 200) {
//   //       final locationHint = json.decode(utf8.decode(response.bodyBytes));
//   //       for (int i = 0; i < locationHint["predictions"].length; i++) {
//   //         locationDescription.add(locationHint["predictions"][i]["description"]);
//   //       }
//   //     }
//   //     else if (response.statusCode == 401) { developer.log("Permission denied at LocationService"); }
//   //     else { developer.log("Failed HTTP when getting profile: ${response.statusCode}"); }
//   //     return locationDescription;
//   //   }
//   //   catch (e) { throw Exception("Failed code when getting hint Location, at map_api.dart. Error type: ${e.toString()}"); }
//   // }


// //   // --------------------  Lấy các thông tin về toạ độ (id, địa chỉ, kinh vĩ độ) -------------------- 

// //   Future< Map<String, dynamic> > getLocationFromInput(String input) async {

// //     developer.log("Call Google Maps Platform Service API. Run `getLocationFromInput($input)`");

// //     Map<String, dynamic> result = {};

// //     // Đọc place_id và địa chỉ
// //     var response = await http.get(Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", { "input": input, "key": key }));
// //     try {
// //       if (response.statusCode == 200) {
// //         final autocomplete = json.decode(utf8.decode(response.bodyBytes));
// //         result["id"] = autocomplete["predictions"][0]["place_id"];
// //         result["addr"] = autocomplete["predictions"][0]["description"];
// //       }
// //       else { developer.log("Failed HTTP when getting profile: ${response.statusCode}"); }
// //     }
// //     catch (e) { throw Exception("Failed code when autocompleting maps, at map_api.dart. Error type: ${e.toString()}"); }



// //     // Đọc kinh độ và vĩ độ
// //     response = await http.get(Uri.https("maps.googleapis.com", "maps/api/geocode/json", { "place_id": result["id"], "key": key }));
// //     try {
// //       if (response.statusCode == 200) {
// //         final locationData = json.decode(utf8.decode(response.bodyBytes));

// //         print("locationData[\"results\"][0][\"geometry\"][\"location\"] = ${ locationData["results"][0]["geometry"]["location"] }");

// //         final lat = locationData["results"][0]["geometry"]["location"]["lat"];
// //         final lng = locationData["results"][0]["geometry"]["location"]["lng"];
// //         result["latlng"] = LatLng(lat, lng);
// //       }
// //       else { developer.log("Failed HTTP when getting profile: ${response.statusCode}"); }
// //     }
// //     catch (e) { throw Exception("Failed code when reading geocoding for autocompleting, at map_api.dart. Error type: ${e.toString()}"); }

// //     return result;
// //   }



// //   // --------------------  lấy danh sách các polyline để vẽ trên bản đồ -------------------- 

// //   Future<Set<Polyline>> getPolyLineByCoords(LatLng pickupPos, LatLng dropoffPos, Color color) async {

// //     developer.log("Call Google Maps Platform Service API. Run `getPolyLineByCoords($pickupPos, $dropoffPos, $color)`");

// //     Set<Polyline> polylines = {};



// //     try {
// //       List<LatLng>? latlenList = await googleMapPolyline?.getCoordinatesWithLocation(origin: pickupPos,
// //                                                                                       destination: dropoffPos,
// //                                                                                       mode: RouteMode.driving);
// //       polylines.add(Polyline(polylineId: const PolylineId("1"), points: latlenList!, color: color));
// //       return polylines;
// //     }
// //     catch (e) { throw Exception("Failed code when getting polylines, at map_api.dart. Error type: ${e.toString()}"); }
// //   }



// //   // --------------------  lấy quãng đường và thời gian -------------------- 

// //   Future< List<int> > getDistanceAndDuration(LatLng pickupPos, LatLng dropoffPos) async {

// //     developer.log("Call Google Maps Platform Service API. Run `getDistanceAndDuration($pickupPos, $dropoffPos)`");

// //     List<int> result = [];    // 0: distance, 1: duration

// //     var response = await http.get(Uri.https("maps.googleapis.com",
// //                                           "maps/api/distancematrix/json",
// //                                           { "units": "metric", "key": key, "origins": latlngToString(pickupPos), "destinations": latlngToString(dropoffPos) }));
    
// //     try {
// //       if (response.statusCode == 200) {
// //         final locationData = json.decode(utf8.decode(response.bodyBytes));
// //         var elements = locationData["rows"][0]["elements"][0];
// //         result.add(elements["distance"]["value"]);    // mét
// //         result.add(elements["duration"]["value"]);    // giây
// //       }
// //       else if (response.statusCode == 401) { developer.log("Permission denied at LocationService"); }
// //       else { developer.log("Failed HTTP when getting profile: ${response.statusCode}"); }
// //       return result;
// //     }
// //     catch (e) { throw Exception("Failed code when using distance matrix, at map_api.dart. Error type: ${e.toString()}"); }
// //   }



// //   // --------------------  Đọc dữ liệu từ toạ độ -------------------- 

// //   Future< Map<String, dynamic> > getLocationFromLatLng(LatLng latlng) async {

// //     developer.log("Call Google Maps Platform Service API. Run `getDistanceAndDuration($latlng)`");

// //     Map<String, dynamic> result = {};

// //     var response = await http.get(Uri.https("maps.googleapis.com", "maps/api/geocode/json", { "latlng": latlngToString(latlng), "key": key }));
// //     try {
// //       if (response.statusCode == 200) {
// //         final locationData = json.decode(utf8.decode(response.bodyBytes));
// //         final placeId = locationData["results"][0]["place_id"];
// //         final addr = locationData["results"][0]["formatted_address"];
// //         result["id"] = placeId;
// //         result["addr"] = addr;
// //         result["latlng"] = latlng;
// //       }
// //       else { developer.log("Failed HTTP when getting profile: ${response.statusCode}"); }
// //     }
// //     catch (e) { throw Exception("Failed code when using geocoding from latlng to get detail, at map_api.dart. Error type: ${e.toString()}"); }

// //     return result;
// //   }


}



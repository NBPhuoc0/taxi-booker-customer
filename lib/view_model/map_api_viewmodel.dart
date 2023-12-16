import 'dart:convert';
import "dart:developer" as developer;
import "package:http/http.dart" as http;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


import '/general/function.dart';
import '/general/constant.dart';
import '/service/map_api_reader.dart';
import '/model/map_api.dart';




class MapAPIViewmodel with ChangeNotifier {

  MapAPI mapAPI = MapAPI();


  void updatePickupLatLng(LatLng value) {
    mapAPI.pickupLatLng = value;
    notifyListeners();
  }

  void updatePickupAddr(String value) {
    mapAPI.pickupAddr = value;
    notifyListeners();
  }

  void updateDropoffLatLng(LatLng value) {
    mapAPI.dropoffLatLng = value;
    notifyListeners();
  }

  void updateDropoffAddr(String value) {
    mapAPI.dropoffAddr = value;
    notifyListeners();
  }

  void updateDriverLatLng(LatLng value) {
    mapAPI.driverLatLng = value;
    notifyListeners();
  }

  // Start to end = S2E
  Future<void> updateS2EPolyline({int vehicleID = 0}) async {
    final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700);
    if (result["status"]) { mapAPI.s2ePolylines = result["polyline"];
                            mapAPI.distance = result["distance"];
                            mapAPI.duration = result["duration"];
                            mapAPI.price = getPrice(result["distance"], vehicleID, goodHour: result["good_hour"], goodWeather: result["good_weather"]); }
    else { developer.log("Unable to find the path between pickup and dropoff locations."); }
    notifyListeners();
  }

  // Driver to start = D2S
  Future<void> updateD2SPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.driverLatLng, mapAPI.pickupLatLng, Colors.brown.shade700);
    if (result["status"]) { mapAPI.d2sPolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between driver and pickup locations."); }
    notifyListeners();
  }

  Future<bool> searchDropoff(String text) async {
    if (text.isEmpty) {
      return Future.value(false);
    }
    final result = await MapAPIReader().getPickedData(text);
    if (result["status"]) {
      mapAPI.dropoffLatLng = LatLng(result["body"].latLong.latitude, result["body"].latLong.longitude);
      mapAPI.dropoffAddr = result["body"].address;
      notifyListeners();
      return Future.value(true);
    }
    else {
      developer.log("Unable to find the dropoff pickedData.");
      notifyListeners();
      return Future.value(false);
    }
  }



  Future<String> getAddr(LatLng value) async {
    final result = await MapAPIReader().getAddr(value);
    if (result["status"]) {
      return result["body"];
    }
    else {
      developer.log("Unable to get the pickup address.");
      return "";
    }
  }



  Future<void> patchPickupLatLng() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.patch(
        Uri.parse(Customer.setLatLong),
        headers: { "Content-Type": "application/json; charset=UTF-8", "Authorization": "Bearer "+ token },
        body: json.encode({ "latitude": mapAPI.pickupLatLng.latitude, "longitude": mapAPI.pickupLatLng.longitude })
      );
    }, "Patch pickup latlng");

    if (result["status"]) {
      developer.log("Successfully patch pickup location.");
    }
  }

  Future<bool> getDriverLocation() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      // print("${Customer.getDriverLocation}?booking_id=${mapAPI.tripId}");
      // return http.get(
      //   Uri.http("${Customer.getDriverLocation}?booking_id=${mapAPI.tripId}"),
      //   headers: {
      //     "Content-Type": "application/json; charset=UTF-8",
      //     "Authorization": "Bearer "+ token
      //   }
      // );
      return http.post(
        Uri.parse(Customer.getDriverLocation),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer "+ token
        },
        body: json.encode({ "booking_id": mapAPI.tripId })
      );
    }, "Get driver location");

    if (result["status"]) {
      developer.log("Successfully get driver data.");
      mapAPI.driverId = result["body"]["id"];
      mapAPI.driverName = result["body"]["fullname"];
      mapAPI.driverPhonenumber = result["body"]["phone"];
      mapAPI.driverLatLng = LatLng(result["body"]["location"]["lat"], result["body"]["location"]["long"]);
      notifyListeners();
      return Future.value(true);
    }
    else {
      return Future.value(false);
    }
  }





  Future<bool> postBookingRequest(String customerPhonenumber, int vehicleID) async {
    var vehicle = "BIKE";
    if ( vehicleID <= 1){
      vehicle = "BIKE";
    }
    else if (vehicleID >= 2){
      vehicle = "CAR";
    }
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.post(
        Uri.parse(Customer.sendBookingRequest),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer "+ token
        },
        body: json.encode({
          "vehicle_type": vehicle,

          "source_address":    mapAPI.pickupAddr,
          "destination_address":   mapAPI.dropoffAddr,
          "source_location" : {
            "lat": mapAPI.pickupLatLng.latitude,
            "lng": mapAPI.pickupLatLng.longitude
          },
          "destination_location" : {
            "lat": mapAPI.dropoffLatLng.latitude,
            "lng": mapAPI.dropoffLatLng.longitude
          },

          "orderTotal":   mapAPI.price,
          "distance": mapAPI.distance,
          "duration": mapAPI.duration
        })
      );
    }, "Update booking request");

    notifyListeners();
    if (result["status"] ) {
      developer.log(result["body"]["_id"]);
      mapAPI.tripId = result["body"]["_id"];  
      return Future.value(true);
    }
    return Future.value(false);
  }

  Future<bool> cancelBookingRequest() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.post(
        Uri.parse(Customer.cancelRequest),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer "+ token
        },
        body: json.encode({ "booking_id": mapAPI.tripId })
      );
    }, "Cancel booking request");

    if (result["status"]) {
      print(result["body"]);
      if (result["body"]["orderStatus"] == "CANCEL") {
        return Future.value(true);
      }
      else {
        return Future.value(false);
      }
    }
    return Future.value(false);
  }

  Future<void> rateDriver(int star) async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.post(
        Uri.parse(Customer.setDriverRate),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer "+ token
        },
        body: json.encode({
          "driver_id": mapAPI.driverId,
          "rate": star
        })
      );
    }, "Rate driver $star stars");

    if (result["status"]) {
      developer.log("Successfully rate driver $star stars.");
    }
  }



  void updateDatetime(int hour, int minute) {
    mapAPI.bookingTime = DateTime.now().toLocal();
    if ((hour != 0) || (minute != 0)) {
      bool addExtraDay = false;
      if (hour < mapAPI.bookingTime.hour) {
        addExtraDay = true;
      }
      else if ((hour == mapAPI.bookingTime.hour) && (minute < mapAPI.bookingTime.minute)) {
        addExtraDay = true;
      }
      DateTime temp = DateTime(mapAPI.bookingTime.year, mapAPI.bookingTime.month, mapAPI.bookingTime.day,
                                  hour, minute, 5, mapAPI.bookingTime.millisecond, mapAPI.bookingTime.microsecond);
      
      if (addExtraDay) {
        temp.add(const Duration(days: 1));
      }
      
      mapAPI.bookingTime = temp;
    }
    notifyListeners();
  }



  void updatePrice(int newPrice) {
    mapAPI.price = newPrice;
    notifyListeners();
  }



  Future<void> saveCustomer() async {
    await mapAPI.saveCustomer();
  }

  Future<void> saveDriver() async {
    await mapAPI.saveDriver();
  }

  Future<void> loadCustomer() async {
    await mapAPI.loadCustomer();
    await updateS2EPolyline();
    notifyListeners();
  }

  Future<void> loadDriver() async {
    await mapAPI.loadDriver();
    await updateD2SPolyline();
    notifyListeners();
  }

  Future<DateTime> loadBookingTime() async {
    final newDate = await mapAPI.loadBookingTime();
    notifyListeners();
    return newDate;
  }

  Future<void> clearAll() async {
    await mapAPI.clearData();
    await mapAPI.loadCustomer();
    await mapAPI.loadDriver();
    notifyListeners();
  }
  
}



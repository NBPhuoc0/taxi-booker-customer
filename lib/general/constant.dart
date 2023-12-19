const String headPoint = "https://gop-taxi.azurewebsites.net";  // Giả lập xãi địa chỉ IP riêng thay vì localhost


class Auth {
  // static const String port = "3001";
  static const String register = "$headPoint/auth/user/signup";
  static const String login = "$headPoint/auth/user/signin";
  static const String logout = "$headPoint/auth/user/logout";
  static const String refresh = "$headPoint/auth/user/refresh";
}

// class Driver {
//   // static const String port = "3003";
//   static const String setLatLong = "$headPoint/setLatLong";
//   static const String userInfo = "$headPoint/userInfor";
//   static const String getHistory = "$headPoint/getHistory";
//   static const String nearbyBookingRequest = "$headPoint/getNearbyBookingRequest";
//   static const String sendBookingAccept = "$headPoint/sendBookingAccept";
//   static const String sendSMS = "$headPoint/sendSMS";
//   static const String sendNotification = "$headPoint/sendNotification";
//   static const String setCompleted = "$headPoint/setCompleted";
// }

class Customer {
  // static const String port = "3004";
  static const String sendBookingRequest = "$headPoint/users/order";
  static const String getHistory = "$headPoint/users/getHistory";
  static const String setLatLong = "$headPoint/users/setLocation";
  static const String userInfo = "$headPoint/users/userInfor";
  static const String setDriverRate = "$headPoint/users/rateDriver";
  static const String getDriverRate = "$headPoint/users/driverRate";
  static const String getDriverLocation = "$headPoint/users/getDriverLocationByBR";
  static const String cancelRequest = "$headPoint/users/cancelOrder";
}



// String key = "AIzaSyBEIQrm2irTkeGi1nfw3ioFsmyiS57T3Ms";  // Google Maps Platform API
String key = "5b3ce3597851110001cf624886c5e7f702de408ba27c7a71dc294d4b";  // Openroute Service API

String web = "https://api.openrouteservice.org";
String directionsService = "v2/directions/driving-car";
String searchGeocoding   = "geocode/search";

String locationWeb = "https://nominatim.openstreetmap.org";



String weatherKey = "82f526738f7ff585d92ec4b470d8f1d3";
String weatherWeb = "https://api.openweathermap.org";
String oneCall = "data/3.0/onecall";


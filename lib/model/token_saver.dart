import 'package:shared_preferences/shared_preferences.dart';




// Singleton
class TokenSaver {

  static final TokenSaver _instance = TokenSaver._internal();
  TokenSaver._internal();

  factory TokenSaver() {
    return _instance;
  }

  Future save(String newAccessToken, String newRefreshToken) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("accessToken",  newAccessToken);
    await sp.setString("refreshToken", newRefreshToken);
  }
  
  Future<String> loadAccessToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("accessToken") ?? "";
  }

  Future<String> loadRefreshToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("refreshToken") ?? "";
  }

  Future clear() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("accessToken",  "");
    await sp.setString("refreshToken", "");
  }
}



import 'dart:async';
import 'dart:convert';
import "dart:developer" as developer;
import "package:http/http.dart" as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '/general/constant.dart';
import '/model/token_saver.dart';

class AccountReader {
  // * Đăng ký tài khoản
  // * RETURN {
  // *   status: true
  // * }
  Future<Map<String, dynamic>> register(
      String username, String phonenumber, String password) async {
    // Đọc url để tìm tài khoản
    var response = await http.post(Uri.parse(Auth.register),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "phone": "$phonenumber",
          "password": password,
          "fullname": username,
        }));

    try {
      Map<String, dynamic> result = {"status": true};

      if ((response.statusCode == 200) || (response.statusCode == 201)) {
      } else {
        developer.log("Failed HTTP when registering: ${response.statusCode}");
        result["status"] = false;
      }
      return result;
    } catch (e) {
      throw Exception(
          "Failed code when trying to register an account, at saved_data.dart. Error type: ${e.toString()}");
    }
  }

  // * Đăng nhập tài khoản
  // *
  // * RETURN: {
  // *   status: <bool>
  // *   body: <Map>
  // * }
  // *
  Future<Map<String, dynamic>> logIn(
      String phonenumber, String password) async {
    Map<String, dynamic> result = {"status": false, "body": null};
    final response = await http.post(Uri.parse(Auth.login),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "phone": "$phonenumber",
          "password": password,
        }));

    try {
      if ((response.statusCode == 200) || (response.statusCode == 201)) {
        developer.log("Successfully find the account's tokens.");

        var jsonVal = json.decode(response.body);
        developer.log(jsonVal.toString());
        final accResponse =
            await http.get(Uri.parse(Customer.userInfo), headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer " + jsonVal["accessToken"]
        });

        if ((accResponse.statusCode == 200) ||
            (accResponse.statusCode == 201)) {
          developer.log("Successfully find the account's data.");
          result["body"] = json.decode(utf8.decode(accResponse.bodyBytes));
          await TokenSaver()
              .save(jsonVal["accessToken"], jsonVal["refreshToken"]);
          result["status"] = true;
        } else {
          developer.log(
              "Failed HTTP when accessing the accessToken during logging in: ${accResponse.statusCode}");
        }
      } else {
        developer.log("Failed HTTP when logging in: ${response.statusCode}");
      }
      return result;
    } catch (e) {
      throw Exception(
          "Failed code when trying to log in, at saved_data.dart. Error type: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> logOut() async {
    Map<String, dynamic> result = {"status": false, "body": null};
    final response = await http.get(Uri.parse(Auth.logout), headers: {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer " + await TokenSaver().loadAccessToken()
    });

    try {
      if ((response.statusCode == 200) || (response.statusCode == 201)) {
        result["status"] = true;
      } else {
        developer.log("Failed HTTP when logging out: ${response.statusCode}");
      }
      return result;
    } catch (e) {
      throw Exception(
          "Failed code when trying to log in, at saved_data.dart. Error type: ${e.toString()}");
    }
  }

  // *
  // * Kiểm tra token ở mỗi lần khai báo, đăng nhập, v.v...
  // *

  bool validToken(String token) {
    return (token.isNotEmpty) && !JwtDecoder.isExpired(token);
  }

  // * Lấy token mới
  // *
  // * RETURN: <String> accessToken
  // *
  Future<String> getNewTokens() async {
    final response = await http.get(Uri.parse(Auth.refresh), headers: {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": "Bearer " + await TokenSaver().loadRefreshToken()
    });

    try {
      if ((response.statusCode == 200) || (response.statusCode == 201)) {
        developer.log("Successfully find the new tokens.");
        final jsonVal = json.decode(response.body);
        await TokenSaver()
            .save(jsonVal["accessToken"], jsonVal["refreshToken"]);
        return jsonVal["accessToken"];
      } else {
        developer
            .log("Failed HTTP when getting new Tokens: ${response.statusCode}");
        developer
            .log("Refresh token: ${await TokenSaver().loadRefreshToken()}");
        // TokenSaver().clear();
        return "";
      }
    } catch (e) {
      throw Exception(
          "Failed code when trying to log in, at saved_data.dart. Error type: ${e.toString()}");
    }
  }

  // * Chạy hàm
  // *
  // * RETURN: {
  // *   status: <bool>
  // *   body: <Map>
  // * }
  // *
  Future<Map<String, dynamic>> toggleFunction(
      Future Function(String token) toggleHttp, String functionDetails,
      {bool callExpired = false}) async {
    if (!callExpired) developer.log("Trying to compile $functionDetails.");

    Map<String, dynamic> result = {"status": false, "body": null};

    String accessToken = await TokenSaver().loadAccessToken();
    if (accessToken.isEmpty) {
      developer.log("[Access token] Empty, no account");
      result["status"] = false;
      return result;
    }

    try {
      final response =
          await toggleHttp(accessToken).timeout(const Duration(seconds: 10));
      switch (response.statusCode) {
        case 200:
        case 201:
          result["status"] = true;
          result["body"] = json.decode(utf8.decode(response.bodyBytes));
          break;

        case 401:
          if (!callExpired) {
            developer.log("[Access token] Expired");
            await getNewTokens();
            result = await toggleFunction(toggleHttp, functionDetails,
                callExpired: true);
          } else {
            developer.log("[Access token & Refresh token] Expired both!");
          }
          break;

        default:
          developer.log(
              "Failed HTTP when compiling $functionDetails. Error HTTP: ${response.statusCode}.");
          developer.log("Response body: ${response.body}");
          break;
      }
    } on TimeoutException catch (e, s) {
      developer.log("The request for $functionDetails took too long. S: $s");
    } catch (e) {
      throw Exception(
          "Failed code when trying to compile $functionDetails, at saved_data.dart. Error type: ${e.toString()}");
    }

    return result;
  }
}

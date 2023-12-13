import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import '/service/firebase_service.dart';
import '/general/constant.dart';
import '/service/account_reader.dart';
import '/model/account_model.dart';
import '/model/token_saver.dart';




class AccountViewmodel with ChangeNotifier {

  AccountModel account = AccountModel();



  // * Tự động load khi mới bắt đầu chương trình
  Future<void> preload() async {

    final result = await AccountReader().toggleFunction((String token) async {
      print(token);
      return http.get(Uri.parse(Customer.userInfo), headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer "+ token
      });
    }, "Preload account");

    if (result["status"]) {
      account.map = result["body"];
    }
    FirebaseService.saveToken(account.map["_id"]);
    notifyListeners();
  }



  // * Đăng ký
  Future<bool> updateRegister(String username, String phonenumber, String password) async {
    var result = await AccountReader().register(username, phonenumber, password);   // Đăng ký
    // Đăng ký thành công => Đăng nhập để lấy token
    if (result["status"]) return await updateLogIn(phonenumber, password);
    FirebaseService.saveToken(account.map["_id"]);
    notifyListeners();
    return Future.value(false);
  }



  // * Đăng nhập
  Future<bool> updateLogIn(String phonenumber, String password) async {
    final result = await AccountReader().logIn(phonenumber, password);
    if (result["status"]) {
      account.map = result["body"];
    }
    FirebaseService.saveToken(account.map["_id"]);
    notifyListeners();
    return Future.value(result["status"]);
  }



  // * Đăng xuất
  Future<void> updateLogOut() async {

    final result = await AccountReader().logOut();

    if (result["status"]) {
      await TokenSaver().clear();
      account.clear();
    }
    
    notifyListeners();
  }
}



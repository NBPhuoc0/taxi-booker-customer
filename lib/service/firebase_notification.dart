import "dart:developer" as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';




class FireBaseAPI {
  static String? token = "";
  static FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
  //static GlobalKey<NavigatorState> nagivatorKey = GlobalKey<NavigatorState>();
  static final _messageStreamController = BehaviorSubject<RemoteMessage>();

  static bool foundDriver = false;



  static Future<void> initialMessage() async {
    NotificationSettings settings = await firebaseMessage.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if ((settings.authorizationStatus == AuthorizationStatus.authorized) || (settings.authorizationStatus == AuthorizationStatus.provisional)) {
      token = await firebaseMessage.getToken();
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      developer.log("Firebase token: $token");
    }
    else {
      developer.log("Unable to notify message. Status: ${settings.authorizationStatus}");
    }
  }


  static void sendMessage({ String text = "Gửi thông tin từ khách hàng lên tài xế." }) {
    FirebaseMessaging.instance.sendMessage(to: token, data: { "request": text });
  }


  static Future<void> listenMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String request = message.data["request"];
      developer.log("Received request: $request");
      developer.log("Receive message: ${message.data}");

      _messageStreamController.sink.add(message);
    });
  }
}


Future<void> handleBackgroundMessage(RemoteMessage message) async {
  developer.log("Title:   ${message.notification?.title}");
  developer.log("Body:    ${message.notification?.body}");
  developer.log("Payload: ${message.data}");
}


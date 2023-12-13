import "dart:developer" as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

import '/firebase_options.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';




final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();

Future initialize() async {
  var androidInitSet = const AndroidInitializationSettings("mipmap/ic_launcher");
  InitializationSettings initSet = InitializationSettings(android: androidInitSet);
  await notification.initialize(initSet);
}

Future<void> showNormalBox(String title, String body) async {
  AndroidNotificationDetails androidNotiDetails = const AndroidNotificationDetails(
    "Id of Notification",
    "This is a channel name",
    playSound: true,
    importance: Importance.max,
    priority: Priority.high
  );
  NotificationDetails notiDetails = NotificationDetails(android: androidNotiDetails);

  await notification.show(0, title, body, notiDetails);
}



Future<void> showFCMBox(RemoteMessage remoteMessage) async {
  AndroidNotificationDetails androidNotiDetails = const AndroidNotificationDetails(
    "Id of Notification",
    "This is a channel name",
    playSound: true,
    importance: Importance.max,
    priority: Priority.high
  );
  NotificationDetails notiDetails = NotificationDetails(android: androidNotiDetails);

  await notification.show(0, remoteMessage.data["body"], remoteMessage.data["title"], notiDetails);
}



Future<void> showBoxWithTimes(String title, String body, DateTime datetime) async {
  AndroidNotificationDetails androidNotiDetails = const AndroidNotificationDetails(
    "Id of Notification",
    "This is a channel name",
    playSound: true,
    importance: Importance.max,
    priority: Priority.high
  );
  NotificationDetails notiDetails = NotificationDetails(android: androidNotiDetails);
  tz.TZDateTime timezone = tz.TZDateTime.from(datetime, tz.local);
  await notification.zonedSchedule(0, title, body, timezone, notiDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime);
}




class FirebaseService {
  
  static String? token = "";
  static String thisUserId = "";
  static FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
  


  static Future<void> initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      firebaseMessage.onTokenRefresh.listen((newToken) async {
        developer.log("UPDATE firebase token: $newToken");
        token = newToken;
        await saveToken(thisUserId);
      });
      developer.log("Firebase token: $token");
    }
    else {
      developer.log("Unable to notify message. Status: ${settings.authorizationStatus}");
    }
  }


  static Future<void> saveToken(String userId) async {
    thisUserId = userId;
    await FirebaseDatabase.instance.ref("users").child(userId).update({ "fcm_token": token });
  }
}



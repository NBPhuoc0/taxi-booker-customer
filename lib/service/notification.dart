import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;



class Noti {

  final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();

  Future initialize() async {
    var androidInitSet = const AndroidInitializationSettings("mipmap/ic_launcher");
    InitializationSettings initSet = InitializationSettings(android: androidInitSet);
    await notification.initialize(initSet);
  }


  Future showBox(String title, String body) async {
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



  Future showBoxWithTimes(String title, String body, DateTime datetime) async {

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

}

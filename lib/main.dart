import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import '/service/firebase_service.dart';
import '/view/navigation.dart' show NavigationChange;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeApp();
  tz.initializeTimeZones();
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      title: "Taxi App For Customer",
      home: NavigationChange()
    );
  }
}



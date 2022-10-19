import 'package:coursework/Coursework/update.dart';
import 'package:flutter/material.dart';
import 'package:coursework/Coursework/my_trip.dart';
import 'package:coursework/Coursework/new_trip.dart';
import 'package:coursework/Coursework/route_names.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        RouteNames.NewTrip: (context) => NewTrip(),
        RouteNames.UpdateTrip:(context) => UpdateTrip(),
        RouteNames.MyTrip: (context) => const MyTrip(),
      },
      initialRoute: RouteNames.MyTrip,
    );
  }
  
}
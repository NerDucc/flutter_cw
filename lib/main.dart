import 'package:flutter/material.dart';
import 'package:coursework/coursework/my_trip.dart';
import 'package:coursework/coursework/new_trip.dart';
import 'package:coursework/coursework/route_names.dart';

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
        RouteNames.MyTrip: (context) => const MyTrip(),
      },
      initialRoute: RouteNames.MyTrip,
    );
  }
  
}
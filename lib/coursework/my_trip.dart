// ignore: implementation_imports
import 'package:coursework/Coursework/route_names.dart';
import 'package:coursework/data/db.dart';
import 'package:coursework/data/trip.dart';
import 'package:flutter/material.dart';

class MyTrip extends StatefulWidget {
  const MyTrip({super.key});

  @override
  State<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {
  late final TripDB _tripStorage;

  @override
  void initState() {
    _tripStorage = TripDB(dbName: "db.sqlite");
    _tripStorage.open();
    super.initState();
  }

  @override
  void dispose() {
    _tripStorage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("M-Expense"),
        ),
        body: StreamBuilder(
            stream: _tripStorage.all(),
            builder: ((context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.waiting:
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final tripList = snapshot.data as List<Trip>;
                  // print(tripList);
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: tripList.length,
                            itemBuilder: ((context, index) {
                              final trip = tripList[index];
                              return ListTile(
                                onTap: () {
                                  // print(trip.id);
                                  Navigator.pushNamed(
                                      context, RouteNames.UpdateTrip,
                                      arguments: {
                                        'id': trip.id,
                                        'name': trip.name,
                                        'date': trip.date,
                                        'participant': trip.participant,
                                        'destination': trip.destination,
                                        'description': trip.description,
                                        'risk': trip.risk,
                                        'transportation': trip.transportation
                                      });

                                },
                                title: Text(
                                  "Trip's name: ${trip.name}",
                                  style: const TextStyle(
                                    color: Color.fromARGB(221, 35, 34, 34),
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(
                                  "Travel date: ${trip.date}",
                                  style: const TextStyle(
                                    color: Color.fromARGB(221, 82, 79, 79),
                                    fontSize: 17,
                                  ),
                                ),
                                trailing: TextButton(
                                    onPressed: () async {
                                      final shouldDelete =
                                          await showDeleteDialog(context);
                                      if (shouldDelete) {
                                        await _tripStorage.delete(trip);
                                      }
                                    },
                                    child: const Icon(
                                        Icons.delete_forever_rounded)),
                              );
                            })),
                      ),
                    ],
                  );
                default:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
              }
            })),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            Navigator.pushNamed(context, RouteNames.NewTrip);
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ));
  }

  Future<bool> showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text("Are you sure you want to delete this trip?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    ).then((value) {
      if (value is bool) {
        return value;
      } else {
        return false;
      }
    });
  }
  
}

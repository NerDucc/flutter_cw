import 'dart:async';
import 'package:coursework/data/trip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TripDB {
  final String dbName;
  Database? _db;
  List<Trip> _tripList = [];
  final _streamController = StreamController<List<Trip>>.broadcast();

  TripDB({required this.dbName});

  Stream<List<Trip>> all() =>_streamController.stream.map((trip) => trip..sort());

  Future<bool> create(
      String tripName,
      String tripDate,
      String tripDescription,
      String tripTransportation,
      String tripParticipant,
      String tripDestination,
      String tripRisk) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final tripID = await db.insert("trips", {
        "name": tripName,
        "date": tripDate,
        "destination": tripDestination,
        "participant": tripParticipant,
        "transportation": tripTransportation,
        "description": tripDescription,
        "risk": tripRisk,
      });
      final trip = Trip(
        id: tripID,
        name: tripName, 
        date: tripDate,
        destination: tripDestination,
        description: tripDescription,
        risk: tripRisk,
        participant: tripParticipant,
        transportation: tripTransportation,
      );
      _tripList.add(trip);
      _streamController.add(_tripList);
      print(_streamController);
      return true;
    } catch (e) {
      print("Error when inserting is ${e}");
      return false;
    }
  }

  Future<List<Trip>> _fetchTrip() async {
    final db = _db;
    if (db == null) {
      print("Nulllllllll");
      return [];
    }
    try {
      final read = await db.query("trips",
          distinct: true,
          columns: [
            "id",
            "name",
            "date",
            "destination",
            "participant",
            "transportation",
            "description",
            "risk",
          ],
          orderBy: "id");

      final tripList = read.map((row) => Trip.fromRow(row)).toList();
      return tripList;

    } catch (e) {

      print("Error when fetching the data is $e");
      return [];
    }
  }

  Future<bool> close() async{
    final db = _db;
    if (db == null) {
      return false;
    }
    await db.close();
    return true;
  }

  Future<bool> open() async {
    if (_db != null) {
      return true;
    }

    final dir = await getApplicationDocumentsDirectory();
    final pathdb = '${dir.path}/${dbName}';
    try {
      final db = await openDatabase(pathdb);
      _db = db;

      const createTable = '''CREATE TABLE IF NOT EXISTS "trips" (
            "id"	INTEGER,
            "name"	TEXT NOT NULL,
            "date"	TEXT NOT NULL,
            "destination"	TEXT NOT NULL,
            "participant"	TEXT,
            "transportation" TEXT,
            "description"	TEXT,
            "risk"	TEXT NOT NULL,
            PRIMARY KEY("id" AUTOINCREMENT)
          ) ''';

      await db.execute(createTable);

      //Read all existing objects in db
      _tripList = await _fetchTrip();
      _streamController.add(_tripList);
      return true;
    } catch (e) {
      print("Error when opening database is $e");
      return false;
    }
  }
}

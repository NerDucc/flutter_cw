import 'package:coursework/coursework/new_trip.dart';



class Trip implements Comparable {
  final int id;
  final String name;
  final String date;
  final String destination;
  final String description;
  final String risk;
  final String participant;
  final String transportation;

  Trip({
    required this.id,
    required this.name,
    required this.date,
    required this.destination,
    required this.description,
    required this.risk,
    required this.participant,
    required this.transportation,
  });

  

  Trip.fromRow(Map<String, Object?> row)
      : id = row["id"] as int,
        name = row["name"] as String,
        date = row["date"] as String,
        destination = row["destination"] as String,
        participant = row["participant"] as String,
        transportation = row["transportation"] as String,
        description = row["description"] as String,
        risk = row["risk"] as String;

  @override
  int compareTo(covariant Trip other) => other.id.compareTo(id);

  @override
  bool operator ==(covariant Trip other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      "Trip ID = $id, trip name = $name, trip date = $date, trip destination = $destination, trip description = $description, trip risk = $risk, participant = $participant, transportation = $transportation";
}

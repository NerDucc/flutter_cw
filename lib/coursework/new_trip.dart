// ignore_for_file: prefer_const_constructors

import 'package:coursework/Coursework/route_names.dart';
import 'package:coursework/data/trip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/db.dart';

enum RiskRequirement { Required, NotRequired }

class NewTrip extends StatefulWidget {
  // const NewTrip({Key? key}) : super(key: key);
  NewTrip({Key? key, this.theTrip}) : super(key: key);

  Trip? theTrip;

  @override
  State<NewTrip> createState() => _NewTripState();
}

class _NewTripState extends State<NewTrip> {
  late final TripDB _tripStorage;
  _NewTripState() {
    _selectval = trip_list[0];
  }
  String result = "Details: ";
  final TextEditingController txtDestination = TextEditingController();
  final TextEditingController txtParticipant = TextEditingController();
  final TextEditingController txtTransportation = TextEditingController();
  final TextEditingController txtDescription = TextEditingController();
  final TextEditingController txtRisk = TextEditingController();
  final TextEditingController txtDate = TextEditingController();
  RiskRequirement? requirement;
  final trip_list = ["Conference", "Signing", "Meeting", "Negotiation"];
  String? _selectval = "";
  bool value = false;

  @override
  void initState() {
    _tripStorage = TripDB(dbName: "db.sqlite");
    _tripStorage.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new trip"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            DropdownButtonFormField(
              value: _selectval,
              items: trip_list
                  .map((e) => (DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      )))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectval = val as String;
                });
              },
              icon: Icon(Icons.arrow_drop_down),
              decoration: InputDecoration(
                labelText: "Name of the trip",
                icon: Icon(Icons.business_center),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: txtDestination,
              decoration: InputDecoration(
                hintText: "Destination",
                icon: const Icon(Icons.place),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
                controller: txtDate,
                // initialValue: DateTime.now() as String,
                decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Enter Date" //label text of field
                    ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(
                          2022), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101));
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    txtDate.text = formattedDate;
                  }
                }),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: txtParticipant,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Participant",
                icon: const Icon(Icons.people),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: txtTransportation,
              decoration: InputDecoration(
                hintText: "Transportation",
                icon: const Icon(Icons.emoji_transportation),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: txtDescription,
              decoration: InputDecoration(
                hintText: "Description",
                icon: const Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: txtRisk,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Risk assessment",
                      icon: const Icon(Icons.crisis_alert),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Switch(
                    value: value,
                    onChanged: (onchanged) {
                      setState(() {
                        value = onchanged;
                      });
                      if (value == true) {
                        txtRisk.text = "Risk assessment required";
                      } else {
                        txtRisk.text = "Risk assessment not required";
                      }
                    })
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                onPressed: () async {
                  saveTrip();
                },
                child: Text('Save',
                    style: TextStyle(
                      fontSize: 18,
                    ))),
          ],
        ),
      ),
    );
  }

  Future<void> saveTrip() async {
    bool shouldAdd = await showAddDialog(context);
    if(shouldAdd)
    {await _tripStorage.create(
      _selectval.toString(),
      txtDate.text,
      txtDescription.text,
      txtTransportation.text,
      txtParticipant.text,
      txtDestination.text,
      txtRisk.text,
    );
    setState(() {
      //close keyboard
      var currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      // _tripStorage.create(_selectval.toString(), txtDate.text, txtDescription.text, txtTransportation.text, txtParticipant.text, txtDestination.text, txtRisk.text);
      // result +=
      //     "\n${_selectval.toString()} |${txtDestination.text} | ${txtParticipant.text} | ${txtTransportation.text} | ${txtDescription.text} | ${txtDate.text} | ${txtRisk.text} ";
      txtDestination.clear();
      txtTransportation.clear();
      txtParticipant.clear();
      txtDescription.clear();
      txtRisk.clear();
      txtDate.clear();

      //print(_selectval.toString(), txtDate.text, txtDescription.text, txtTransportation.text, txtParticipant.text, txtDestination.text, txtRisk.text);
      // print(result);
      Navigator.pushNamed(context, RouteNames.MyTrip);
    });}
  }

  @override
  void dispose() {
    txtDestination.dispose();
    txtTransportation.dispose();
    txtParticipant.dispose();
    txtDescription.dispose();
    txtDate.dispose();
    txtRisk.dispose();
    super.dispose();
  }

  Future<bool> showAddDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              """Name of the trip: ${_selectval.toString()}\nDate of the trip: ${txtDate.text}\nDestination: ${txtDestination.text}\nParticipant: ${txtParticipant.text}\nTransportation: ${txtTransportation.text}\nRisk assessment: ${txtRisk.text}\nDescription: ${txtDescription.text}"""),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Back"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Save"),
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

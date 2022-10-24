// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:coursework/Coursework/route_names.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import '../data/db.dart';

enum RiskRequirement { Required, NotRequired }

class UpdateTrip extends StatefulWidget {
  // const NewTrip({Key? key}) : super(key: key);
  const UpdateTrip({Key? key}) : super(key: key);

  @override
  State<UpdateTrip> createState() => _UpdateTripState();
}

class _UpdateTripState extends State<UpdateTrip> {
  late final TripDB _tripStorage;
  final _formKey = GlobalKey<FormState>();

  _UpdateTripState() {
    _selectval = trip_list[0];
  }
  String result = "Details: ";
  int id = 0;
  TextEditingController txtDestination = TextEditingController();
  TextEditingController txtParticipant = TextEditingController();
  TextEditingController txtTransportation = TextEditingController();
  TextEditingController txtDescription = TextEditingController();
  TextEditingController txtDate = TextEditingController();
  TextEditingController txtRisk = TextEditingController();
  // DateTime _dateTime = {$(DateTime.da)};
  RiskRequirement? requirement;
  final trip_list = ["Conference", "Signing", "Meeting", "Negotiation"];
  String? _selectval = "";
  var value = false;
  bool riskValue = false;

  @override
  void initState() {
    _tripStorage = TripDB(dbName: "db.sqlite");
    _tripStorage.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final received = args as Map;
    id = received['id'];
    txtDestination.text = received['destination'];
    txtDate.text = received['date'];
    txtDescription.text = received['description'];
    txtParticipant.text = received['participant'];
    txtRisk.text = received['risk'];
    txtTransportation.text = received['transportation'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update trip"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          key: _formKey,
          children: [
            DropdownButtonFormField(
              value: received['name'],
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
              validator: requiredField,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                validator: requiredField,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: txtDate,
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today), //icon of text field
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
              validator: MultiValidator([
                RequiredValidator(errorText: "Transportation required"),
              ]),
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
                    validator: requiredField,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: txtRisk,
                    readOnly: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(Icons.health_and_safety_sharp),
                            content:
                                const Text("Risk assessment for the trip!!!"),
                            actionsAlignment: MainAxisAlignment.end,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                  txtRisk.text = "Not Required";
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  txtRisk.text = "Required";
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Risk assessment",
                      icon: const Icon(Icons.crisis_alert),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                //  Switch(
                //     value: value,
                //     onChanged: (onchanged) async {
                //       setState(() {
                //         value = onchanged;
                //       });
                //       value = onchanged;
                //     })
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveTrip();
                  }
                },
                child: Text('Update',
                    style: TextStyle(
                      fontSize: 18,
                    ))),
          ],
        ),
      ),
    );
  }

  Future<void> saveTrip() async {
    bool shouldUpdate = await showUpdateDialog(context);

    if (shouldUpdate) {
      await _tripStorage.update(
        id,
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
        txtDestination.clear();
        txtTransportation.clear();
        txtParticipant.clear();
        txtDescription.clear();

        txtDate.clear();

        Navigator.pushNamed(context, RouteNames.MyTrip);
      });
    }
  }

  @override
  void dispose() {
    txtDestination.dispose();
    txtTransportation.dispose();
    txtParticipant.dispose();
    txtDescription.dispose();
    txtDate.dispose();
    super.dispose();
  }

  Future<bool> showUpdateDialog(BuildContext context) {
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

  String? requiredField(String? value) {
    if(value == null || value.isEmpty){
      return "This field is not allowed to be empty";
    }
    return null;
  }
}

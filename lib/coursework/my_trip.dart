// ignore: implementation_imports
// ignore_for_file: prefer_const_constructors
import 'package:coursework/Coursework/route_names.dart';
import 'package:coursework/data/db.dart';
import 'package:coursework/data/trip.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyTrip extends StatefulWidget {
  const MyTrip({super.key});

  @override
  State<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {
  late final TripDB _tripStorage;
  final _formKey = GlobalKey<FormState>();
  final tripList = ["Conference", "Signing", "Meeting", "Negotiation"];
  String? _selectval = "";

  final TextEditingController txtDestination = TextEditingController();
  final TextEditingController txtParticipant = TextEditingController();
  final TextEditingController txtTransportation = TextEditingController();
  final TextEditingController txtDescription = TextEditingController();
  final TextEditingController txtRisk = TextEditingController();
  final TextEditingController txtDate = TextEditingController();

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
                  if (tripList.isEmpty) {
                    return EmptyWidget(
                      image: null,
                      packageImage: PackageImage.Image_1,
                      title: 'No item in the app yes',
                      subTitle: 'No item available yet',
                      titleTextStyle: TextStyle(
                    fontSize: 22,
                    color: Color(0xff9da9c7),
                    fontWeight: FontWeight.w500,
                      ),
                      subtitleTextStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xffabb8d6),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: tripList.length,
                              itemBuilder: ((context, index) {
                                final trip = tripList[index];
                                return ListTile(
                                  onTap: () async {
                                    await showUpdate(
                                      context,
                                      trip,
                                    );
                                    // print(trip.id);
                                    // Navigator.pushNamed(
                                    //     context, RouteNames.UpdateTrip,
                                    //     arguments: {
                                    //       'id': trip.id,
                                    //       'name': trip.name,
                                    //       'date': trip.date,
                                    //       'participant': trip.participant,
                                    //       'destination': trip.destination,
                                    //       'description': trip.description,
                                    //       'risk': trip.risk,
                                    //       'transportation': trip.transportation
                                    //     });
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
                  }

                default:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
              }
            })),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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
          title: const Text("Delete trip!!"),
          content: const Text("This trip will be deleted permanently"),
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

  Future<Trip?> showUpdate(BuildContext context, Trip trip) {
    txtDestination.text = trip.destination;
    txtDate.text = trip.date;
    txtDescription.text = trip.description;
    txtParticipant.text = trip.participant;
    txtRisk.text = trip.risk;
    txtTransportation.text = trip.transportation;
    _selectval = trip.name;
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: ((context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        validator: requiredField,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        value: _selectval,
                        items: tripList
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
                        height: 18.0,
                      ),
                      TextFormField(
                        validator: requiredField,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: txtDestination,
                        decoration: InputDecoration(
                          labelText: "Destination",
                          hintText: "Destination",
                          icon: const Icon(Icons.place),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      TextFormField(
                          validator: requiredField,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: txtDate,
                          // initialValue: DateTime.now() as String,
                          decoration: InputDecoration(
                              icon: Icon(
                                  Icons.calendar_today), //icon of text field
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
                        height: 18.0,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              validator: requiredField,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: txtRisk,
                              readOnly: true,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: const Text(
                                          "Risk assessment for the trip!!!"),
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
                          // Switch(
                          //     value: value,
                          //     onChanged: (onchanged) {
                          //       setState(() {
                          //         value = onchanged;
                          //       });
                          //     })
                        ],
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      TextFormField(
                        controller: txtDescription,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Description",
                          icon: const Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      TextFormField(
                        controller: txtParticipant,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Participant",
                          hintText: "Participant",
                          icon: const Icon(Icons.people),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      TextFormField(
                        validator: requiredField,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: txtTransportation,
                        decoration: InputDecoration(
                          labelText: "Transportation",
                          hintText: "Transportation",
                          icon: const Icon(Icons.emoji_transportation),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: 120),
                          ElevatedButton.icon(
                              icon: Icon(Icons.drive_file_move_sharp),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  saveTrip(trip.id);
                                }
                              },
                              label: Text('Save',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ))),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        }));
  }

  Future<void> saveTrip(id) async {
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
        txtRisk.clear();
        txtDate.clear();

        Navigator.of(context).pop();
      });
    }
  }

  showUpdateDialog(BuildContext context) {
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
                // txtDestination.dispose();
                // txtTransportation.dispose();
                // txtParticipant.dispose();
                // txtDescription.dispose();
                // txtDate.dispose();
                // txtRisk.dispose();
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

  @override
  void dispose() {
    _tripStorage.close();
    super.dispose();
  }

  String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is not allowed to be empty";
    }
    return null;
  }
}

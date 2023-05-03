import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:project1/models/ReminderModel.dart';
import 'package:project1/screens/locationPage.dart';
import 'package:project1/screens/mapPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../helper/databaseHelper.dart';
import '../providers/locationProvider.dart';

class SetReminder extends StatefulWidget {
  @override
  _SetReminderState createState() => _SetReminderState();
}

class _SetReminderState extends State<SetReminder> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _messageController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  // Completer<GoogleMapController> _controller = Completer();
  // LocationData? _currentLocation;

  // Location _locationService = Location();
  // CameraPosition _initialCameraPosition = CameraPosition(target: LatLng(0, 0));
  // Set<Marker> _markers = {};
  final dbHelper = ReminderDatabaseHelper.instance;
  String? _dateTime;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _locationName;
  double? _radius;
  int? _reminderId;
  bool _isActive = true;

  @override
  // void initState() {
  //   super.initState();
  //   _locationService.getLocation().then((locationData) {
  //     _currentLocation = locationData;
  //     _initialCameraPosition = CameraPosition(
  //         target:
  //             LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
  //         zoom: 15.0);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reminder'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Active'),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    labelText: 'Message',
                  ),
                  controller: _messageController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a message for the reminder';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  // onChanged: (value) {
                  //   _locationName = value;
                  // },
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Radius (in meters)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                  // onChanged: (value) {
                  //   _radius = double.parse(value);
                  // },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a radius for the location';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_startTime == null
                          ? "Select Start Time"
                          : _startTime!.format(context)),
                      ElevatedButton(
                        child: Text('Select Start Time'),
                        onPressed: () => _selectTime(context, "start"),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_endTime == null
                          ? "Select End Time"
                          : _endTime!.format(context)),
                      ElevatedButton(
                        child: Text('Select End Time'),
                        onPressed: () => _selectTime(context, "end"),
                      ),
                    ],
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     ElevatedButton(
                //       child: Text('Set Date and Time'),
                //       onPressed: () {
                //         DatePicker.showDateTimePicker(context,
                //             showTitleActions: true, onChanged: (date) {
                //           print('change $date');
                //         }, onConfirm: (date) {
                //           print('confirm $date');
                //           setState(() {
                //             _dateTime = date.toString();
                //           });
                //           _dateTime = date.toString();
                //         }, currentTime: DateTime.now(), locale: LocaleType.en);
                //       },
                //     ),
                //     _dateTime == null ? Container() : Text(_dateTime.toString())
                //   ],
                // ),
                SizedBox(
                  height: 16.0,
                ),
                // Container(
                //   height: 200,
                //   child: GoogleMap(
                //       initialCameraPosition: _initialCameraPosition,
                //       markers: _markers,
                //       onMapCreated: (GoogleMapController controller) {
                //         _controller.complete(controller);
                //       },
                //       onTap: (LatLng location) {
                //         _markers.clear();
                //         setState(() {
                //           _markers.add(
                //             Marker(
                //               markerId: MarkerId(location.toString()),
                //               position: location,
                //               infoWindow: InfoWindow(title: _locationName),
                //             ),
                //           );
                //         });
                //       }),
                // ),
                SizedBox(
                  height: 16.0,
                ),

                SizedBox(
                  height: 16.0,
                ),

                Text(Provider.of<LocationProvider>(context, listen: true)
                    .salonsAddress
                    .toString()),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LocationPage()));
                    },
                    child: const Text("Navigate")),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    int id = 102;
                    if (_formKey.currentState!.validate() &&
                        _endTime != null &&
                        _startTime != null &&
                        Provider.of<LocationProvider>(context, listen: false)
                                .salonsAddress !=
                            null &&
                        _radius != null) {
                      await dbHelper
                          .insert(Reminder(
                              title: _messageController.text,
                              location: LatLng(
                                  Provider.of<LocationProvider>(context,
                                          listen: false)
                                      .lat!,
                                  Provider.of<LocationProvider>(context,
                                          listen: false)
                                      .long!),
                              radius: _radius!,
                              startTime: _startTime!.format(context),
                              endTime: _endTime!.format(context),
                              address: Provider.of<LocationProvider>(context,
                                      listen: false)
                                  .salonAddress!,
                              id: id))
                          .then((value) => print("Added"));
// _saveReminder();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _selectedTime = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context, String time) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        time == "start" ? _startTime = pickedTime : _endTime = pickedTime;
      });
    }
  }

  // Future<String> _getLocationName(LatLng location) async {
  //   String locationName = '';
  //   List<Placemark> placemarks = await Geolocator()
  //       .placemarkFromCoordinates(location.latitude, location.longitude);
  //   if (placemarks != null && placemarks.isNotEmpty) {
  //     locationName = placemarks.first.name;
  //   }
  //   return locationName;
  // }

  // _saveReminder() async {
  //   Database db = await openDatabase('reminders.db', version: 1,
  //       onCreate: (Database db, int version) async {
  //     await db.execute(
  //         'CREATE TABLE reminders (id INTEGER PRIMARY KEY, message TEXT, location_name TEXT, latitude REAL, longitude REAL, radius REAL, date_time TEXT, is_active INTEGER)');
  //   });
  // }
}

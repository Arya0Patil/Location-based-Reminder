import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class SetReminder extends StatefulWidget {
  @override
  _SetReminderState createState() => _SetReminderState();
}

class _SetReminderState extends State<SetReminder> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _messageController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentLocation;
  Location _locationService = Location();
  CameraPosition _initialCameraPosition = CameraPosition(target: LatLng(0, 0));
  Set<Marker> _markers = {};
  String? _dateTime;
  String? _locationName;
  double? _radius;
  int? _reminderId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _locationService.getLocation().then((locationData) {
      _currentLocation = locationData;
      _initialCameraPosition = CameraPosition(
          target:
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 15.0);
    });
  }

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
                TextFormField(
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
                    labelText: 'Location Name',
                  ),
                  onChanged: (value) {
                    _locationName = value;
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Radius (in meters)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _radius = double.parse(value);
                  },
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
                ElevatedButton(
                  child: Text('Set Date and Time'),
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onChanged: (date) {
                      print('change $date');
                    }, onConfirm: (date) {
                      print('confirm $date');
                      _dateTime = date.toString();
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  height: 200,
                  child: GoogleMap(
                      initialCameraPosition: _initialCameraPosition,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onTap: (LatLng location) {
                        _markers.clear();
                        setState(() {
                          _markers.add(
                            Marker(
                              markerId: MarkerId(location.toString()),
                              position: location,
                              infoWindow: InfoWindow(title: _locationName),
                            ),
                          );
                        });
                      }),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
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
                SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:project1/helper/locationHelper.dart';
import 'package:provider/provider.dart';

import '../providers/locationProvider.dart';
import 'package:another_flushbar/flushbar.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Position? currentPosition;
  var latitude;
  var longitude;
  var geoLocator = Geolocator();
  bool isLoading = false;
  String? salonAddress;

  loc.Location location = loc.Location();
  bool? _serviceEnabled;
  loc.PermissionStatus? locationPermission;

  String mapAPIKey = "AIzaSyAzi5L_e6oxafawGbDvxgtaMv66h_vbk9A";

  Future getAddress() async {
    Position position = await Geolocator.getCurrentPosition();
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapAPIKey}";
    var response = await RequestAssistant.getRequest(url);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      Provider.of<LocationProvider>(context, listen: false)
          .setLat(position.latitude);
      Provider.of<LocationProvider>(context, listen: false)
          .setLng(position.longitude);
      Provider.of<LocationProvider>(context, listen: false)
          .setLocationList(response['results'][0]['address_components']);
      salonAddress = response['results'][0]['formatted_address'];
      Provider.of<LocationProvider>(context, listen: false)
          .setAddress(response['results'][0]['formatted_address']);
    });
    if (response != 'failed') {
      setState(() {
        for (int i = 0;
            i <
                Provider.of<LocationProvider>(context, listen: false)
                    .locationList
                    .length;
            i++) {
          Provider.of<LocationProvider>(context, listen: false).locationList[i]
                      ['types'][0] ==
                  'locality'
              ? Provider.of<LocationProvider>(context, listen: false)
                  .setLocality(
                      Provider.of<LocationProvider>(context, listen: false)
                          .locationList[i]['long_name'])
              : '';
          Provider.of<LocationProvider>(context, listen: false).locationList[i]
                      ['types'][0] ==
                  'administrative_area_level_3'
              ? Provider.of<LocationProvider>(context, listen: false).setCity(
                  Provider.of<LocationProvider>(context, listen: false)
                      .locationList[i]['long_name'])
              : '';
        }
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future getNewAddress() async {
    setState(() {
      isLoading = true;
    });
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$mapAPIKey";
    var response = await RequestAssistant.getRequest(url);
    setState(() {
      Provider.of<LocationProvider>(context, listen: false).setLat(latitude);
      Provider.of<LocationProvider>(context, listen: false).setLng(longitude);
      Provider.of<LocationProvider>(context, listen: false)
          .setLocationList(response['results'][0]['address_components']);
      salonAddress = response['results'][0]['formatted_address'];
      Provider.of<LocationProvider>(context, listen: false)
          .setAddress(response['results'][0]['formatted_address']);
    });
    if (response != 'failed') {
      setState(() {
        for (int i = 0;
            i <
                Provider.of<LocationProvider>(context, listen: false)
                    .locationList
                    .length;
            i++) {
          Provider.of<LocationProvider>(context, listen: false).locationList[i]
                      ['types'][0] ==
                  'locality'
              ? Provider.of<LocationProvider>(context, listen: false)
                  .setLocality(
                      Provider.of<LocationProvider>(context, listen: false)
                          .locationList[i]['long_name'])
              : '';
          Provider.of<LocationProvider>(context, listen: false).locationList[i]
                      ['types'][0] ==
                  'administrative_area_level_3'
              ? Provider.of<LocationProvider>(context, listen: false).setCity(
                  Provider.of<LocationProvider>(context, listen: false)
                      .locationList[i]['long_name'])
              : '';
        }
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void checkPermissions() async {
    setState(() {
      isLoading = true;
    });
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      await location.requestService();
      _serviceEnabled = await location.serviceEnabled();
      if (_serviceEnabled!) {
        locationPermission = await location.hasPermission();
        if (locationPermission != loc.PermissionStatus.granted) {
          await location.requestPermission();
          locationPermission = await location.hasPermission();
          if (locationPermission == loc.PermissionStatus.granted) {
            try {
              getAddress();
            } catch (e) {
              print(e);
              locationNotReceivedDialog(context);
            }
          } else {
            locationPermissionDialog(context);
          }
        } else {
          try {
            getAddress();
          } catch (e) {
            print(e);
            locationNotReceivedDialog(context);
          }
        }
      } else {
        locationServiceDialog(context);
      }
    } else {
      locationPermission = await location.hasPermission();
      if (locationPermission != loc.PermissionStatus.granted) {
        await location.requestPermission();
        locationPermission = await location.hasPermission();
        if (locationPermission == loc.PermissionStatus.granted) {
          try {
            getAddress();
          } catch (e) {
            print(e);
            locationNotReceivedDialog(context);
          }
        } else {
          locationPermissionDialog(context);
        }
      } else {
        try {
          getAddress();
        } catch (e) {
          print(e);
          locationNotReceivedDialog(context);
        }
      }
    }
  }

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: kPrimaryColor,
        title: Text(
          "Set salon's location ",
        ),
      ),
      body: latitude == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Press and hold marker to move to desired location',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude!, longitude!),
                      zoom: 14.0,
                    ),
                    myLocationEnabled: true,
                    // ignore: prefer_collection_literals
                    markers: Set<Marker>.of(
                      <Marker>[
                        Marker(
                            draggable: true,
                            markerId: const MarkerId("1"),
                            position: LatLng(latitude, longitude),
                            icon: BitmapDescriptor.defaultMarker,
                            infoWindow: const InfoWindow(
                              title: 'Move pin to your salon location',
                            ),
                            onDragEnd: ((newPosition) {
                              setState(() {
                                latitude = newPosition.latitude;
                                longitude = newPosition.longitude;
                              });
                              getNewAddress();
                            }))
                      ],
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    salonAddress == null
                        ? 'Selected address : '
                        : 'Selected address :  ${salonAddress.toString()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Confirm location')),
                )
              ],
            ),
    );
  }

  Future<void> locationNotReceivedDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final theme = Theme.of(context);
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 30,
                      // color: kPrimaryColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Unable to get location',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Please try again to get your location',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        onPressed: () async {
                          checkPermissions();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_searching,
                              // color: kPrimaryColor,
                            ),
                            Text(
                              '  Try again',
                              // style: TextStyle(color: kPrimaryColor),
                            )
                          ],
                        )),
                    const Divider(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> locationPermissionDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final theme = Theme.of(context);
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 30,
                      // color: kPrimaryColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Location permission not enabled',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Please enable location permission for better experience',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        onPressed: () async {
                          await location.requestPermission();
                          loc.PermissionStatus locationPermission =
                              await location.hasPermission();
                          if (locationPermission !=
                              loc.PermissionStatus.granted) {
                            Flushbar(
                              message: "Please enable location permission",
                              messageSize: 15,
                              duration: const Duration(seconds: 5),
                              margin: const EdgeInsets.all(8),
                              borderRadius: BorderRadius.circular(8),
                              flushbarStyle: FlushbarStyle.FLOATING,
                              icon: const Icon(Icons.info_outline,
                                  color: Colors.blue),
                              flushbarPosition: FlushbarPosition.BOTTOM,
                              mainButton: TextButton(
                                onPressed: () {
                                  Geolocator.openAppSettings();
                                },
                                child: const Text(
                                  "Enable",
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ),
                            ).show(dialogContext);
                          } else {
                            checkPermissions();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_searching,
                              // color: kPrimaryColor,
                            ),
                            Text(
                              '  Enable location permission',
                              // style: TextStyle(color: kPrimaryColor),
                            )
                          ],
                        )),
                    const Divider(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> locationServiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final theme = Theme.of(context);
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 30,
                      // color: kPrimaryColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Location permission not enabled',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Please enable location permission for better experience',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        onPressed: () async {
                          await location.requestService();
                          bool serviceEnabled = await location.serviceEnabled();
                          loc.PermissionStatus locationPermission =
                              await location.hasPermission();
                          if (serviceEnabled == true) {
                            Navigator.pop(dialogContext);
                            if (locationPermission !=
                                loc.PermissionStatus.granted) {
                              locationPermissionDialog(dialogContext);
                            } else {
                              checkPermissions();
                            }
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_searching,
                              // color: kPrimaryColor,
                            ),
                            Text(
                              '  Enable device location',
                              // style: TextStyle(color: kPrimaryColor),
                            )
                          ],
                        )),
                    const Divider(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

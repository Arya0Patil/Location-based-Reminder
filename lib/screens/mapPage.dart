import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _center = const LatLng(37.7749, -122.4194);
  LatLng? _currentLatLng;

  @override
  void initState() {
    // TODO: implement initState
    GetLocation();
    super.initState();
  }

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  GetLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denied permission
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case where the user permanently denied permission
    }

// Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMarkerDragEnd(LatLng position) {
    setState(() {
      _currentLatLng = position;
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(_currentLatLng.toString()),
        position: _currentLatLng!,
        draggable: true,
        onDragEnd: _onMarkerDragEnd,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: SizedBox(
        height: 400,
        width: 300,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 10.0,
          ),
          onTap: (LatLng position) {
            setState(() {
              _currentLatLng = position;
              _markers.clear();
              _markers.add(Marker(
                markerId: MarkerId(_currentLatLng.toString()),
                position: _currentLatLng!,
                draggable: true,
                onDragEnd: _onMarkerDragEnd,
              ));
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentLatLng != null) {
            Navigator.pop(context, _currentLatLng);
          }
        },
        label: const Text('Confirm Location'),
      ),
    );
  }
}

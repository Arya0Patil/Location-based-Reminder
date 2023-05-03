import 'package:google_maps_flutter/google_maps_flutter.dart';

class Reminder {
  final String title;
  final LatLng location;
  final double radius;
  final String startTime;
  final String endTime;
  final String address;
  final int id;

  Reminder({
    required this.title,
    required this.location,
    required this.radius,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'radius': radius,
      'start_time': startTime,
      'end_time': endTime,
      'address': address,
      'id': id,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      title: map['title'],
      location: LatLng(map['latitude'], map['longitude']),
      radius: map['radius'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      address: map['address'],
      id: map['id'],
    );
  }
}

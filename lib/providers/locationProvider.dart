import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  String? salonsAddress;
  String? salonCity;
  String? salonLocality;
  double? long;
  double? lat;
  var locationList = [];
  String? get salonAddress => salonsAddress;

  setAddress(address) {
    salonsAddress = address;
    notifyListeners();
  }

  setLocationList(list) {
    locationList = list;
    notifyListeners();
  }

  setCity(city) {
    salonCity = city;
    notifyListeners();
  }

  setLat(latitude) {
    lat = latitude;
    notifyListeners();
  }

  setLng(longitude) {
    long = longitude;
    notifyListeners();
  }

  setLocality(locality) {
    salonLocality = locality;
    notifyListeners();
  }
}

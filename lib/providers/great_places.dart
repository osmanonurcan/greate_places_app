import 'dart:io';
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../helpers/db_helper.dart';
import '../helpers/location_helper.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  Place findById(String id) {
    return _items.firstWhere((place) => place.id == id);
  }

  Future<void> addPlace(
      String title, File image, PlaceLocation location) async {
    final address = await LocationHelper.getPlaceAddress(
        location.latitude, location.longitude);
    final uptadedLocation = PlaceLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address);
    final newPlace = Place(
        id: DateTime.now().toString(),
        title: title,
        location: uptadedLocation,
        image: image);
    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'loc_lat': newPlace.location.latitude,
      'loc_lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
  }

  Future<void> fetchAndSetPlaces() async {
    final placeList = await DBHelper.getData('user_places');

    _items = placeList
        .map((place) => Place(
              id: place['id'],
              title: place['title'],
              location: PlaceLocation(
                latitude: place['loc_lat'],
                longitude: place['loc_lng'],
                address: place['address'],
              ),
              image: File(place['image']),
            ))
        .toList();
    notifyListeners();
  }
}

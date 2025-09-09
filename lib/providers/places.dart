import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:section_13/models/place.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart' as sql;

Future<sql.Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  return await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1,
  );
}

class PlaceNotifier extends StateNotifier<List<Place>> {
  PlaceNotifier() : super([]);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    state = data
        .map(
          (item) => Place(
            id: item['id'] as String,
            title: item['title'] as String,
            image: File(item['image'] as String),
            location: PlaceLocation(
              latitude: item['lat'] as double,
              longitude: item['lng'] as double,
              address: item['address'] as String,
            ),
          ),
        )
        .toList();
  }

  void addPlace(Place place, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': place.id,
      'title': place.title,
      'image': copiedImage.path,
      'lat': location.latitude,
      'lng': location.longitude,
      'address': location.address,
    });
    state = [
      Place(title: place.title, image: copiedImage, location: location),
      ...state,
    ];
  }

  void removePlace(Place place) {
    state = state.where((p) => p.title != place.title).toList();
  }
}

final placesProvider = StateNotifierProvider<PlaceNotifier, List<Place>>((ref) {
  return PlaceNotifier();
});

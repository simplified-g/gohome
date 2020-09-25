import 'dart:async';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

//import 'package:location/location.dart';

import '../components/notificationPill.dart';
import '../services/cityContentServices.dart';
import '../classes/property.dart';
import '../components/propertyList.dart';
import './eachProperty.dart';

class NearbyPlaces extends StatefulWidget {
  final Property item;
  final Address location;
  final String search;

  NearbyPlaces({this.item, this.location, this.search});

  @override
  State<StatefulWidget> createState() => _NearbyPlacestate(
        item: item,
        location: location,
        search: search,
      );
}

class _NearbyPlacestate extends State<NearbyPlaces> {
  final Property item;
  final Address location;
  final String search;

  _NearbyPlacestate({
    this.item,
    this.location,
    this.search,
  });

  Completer<GoogleMapController> _controller = Completer();

  // initial camera position
  CameraPosition _cameraPos;

  // A map of markers
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  // function to generate random ids
  int generateIds() {
    var rng = new Random();
    var randomInt;
    randomInt = rng.nextInt(100);
    print(rng.nextInt(100));
    return randomInt;
  }

  static const apiKey = 'AIzaSyACDaIJn21j0iIg3DizilxBRa3uJRuuwKQ';

  List nearestLat = List();
  List nearestLong = List();

  Set<Marker> _markers = {};
  static List<Set<Marker>> _markerList = List();
  LatLng _lastMapPosition;
  MapType _currentMapType = MapType.normal;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
//    print(await searchNearby("hotel"));
  }

  Marker markerPointers;
  bool findingNearbyLocations = true;
  @override
  void initState() {
    _lastMapPosition =
        LatLng(location.coordinates.latitude, location.coordinates.longitude);
    if (this.search != null) {
      searchNearby(this.search);
    }
    super.initState();
    setState(() {
      this.markerPointers = Marker(
        markerId: MarkerId('Property'),
        position: LatLng(
            location.coordinates.latitude, location.coordinates.longitude),
        infoWindow: InfoWindow(title: item.title, snippet: item.description),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
    // _onAddMarkerButtonPressed();
  }

  searchNearby(String keyword) async {
    if(mounted) {
      setState(() {
        findingNearbyLocations = true;
      });
    }
    Fluttertoast.showToast(
        msg: "Finding NearBy Locations. Please waiting",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);

    var dio = Dio();
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    var parameters = {
      'key': apiKey,
      'location':
          '${location.coordinates.latitude}, ${location.coordinates.longitude}',
      'radius': '800',
      'keyword': keyword
    };

    var response = await dio.get(url, queryParameters: parameters);
    print("--------------------------------------------------------");
    print(response.data['status']);
    if (response.data['status'] == "OK") {
      var results = response.data['results'];
      this._markers.clear();
      results.forEach((f) {
        setState(() {
          this._markers.add(Marker(
                markerId: MarkerId(f['id']),
                position: LatLng(f["geometry"]["location"]["lat"],
                    f["geometry"]["location"]["lng"]),
                infoWindow: InfoWindow(
                    title: f['name'], snippet: f['types'].toString()),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ));
        });
      });
      Fluttertoast.showToast(
          msg: "NearBy Locations Found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: " Nothing Found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    if(mounted) {
      setState(() {
        findingNearbyLocations = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  int i = 0;

  _onAddMarkerButtonPressed() {
    if (i < nearestLat.length) {
      _markers.add(
        Marker(
            markerId: MarkerId(_lastMapPosition.toString()),
            position: LatLng(
                location.coordinates.latitude, location.coordinates.longitude),
            infoWindow: InfoWindow(
              title: "This is a title",
              snippet: "This is a snippet",
            ),
            icon: BitmapDescriptor.defaultMarker),
      );

      _markerList.add(_markers);
      i++;
      _onAddMarkerButtonPressed();
    }
    print(_markers);
  }

//print(_onAddMarkerButtonPressed());

  void _getLocation() async {
    final Map<String, Marker> _markers = {};

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(
            location.coordinates.latitude, location.coordinates.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Locations'),
        backgroundColor: Color(0xFF79c942),
        actions: <Widget>[
          this.search != null ? IconButton(icon: Icon(Icons.refresh),
              onPressed: () => searchNearby(this.search)): null
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            //9.060352,7.4514432
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(location.coordinates.latitude,
                  location.coordinates.longitude),
              zoom: 15.0,
            ),
            mapType: _currentMapType,
            markers: {this.markerPointers, ...this._markers},
            myLocationEnabled: true,
            onCameraMove: _onCameraMove,
          ),
          this.search != null && findingNearbyLocations ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: Color(0x44000000),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ) : Container()
          /* Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  button(_onMapTypeButtonPressed, Icons.map, 1),
                  SizedBox(
                    height: 16.0,
                  ),
                  button(_onAddMarkerButtonPressed, Icons.add_location, 3),
                ],
              ),
            ),
          ), */
        ],
      ),
    );
  }
}

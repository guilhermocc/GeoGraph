import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epictour/person_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.userId}) : super(key: key);
  final String userId;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _center = LatLng(-23.563900, -46.653641);
  final Map<String, Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;

  final geoLocator = Geolocator();
  final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high, distanceFilter: 1, timeInterval: 5000);
  StreamSubscription<Position> positionSubscription;
  GoogleMapController mapController;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  dispose() {
    positionSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    setPositionEventsSubscription();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/custom_person.png');
  }

  void setPositionEventsSubscription() {
    positionSubscription = geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      print("*** GEOLOCATION UPDATE EVENT FIRED ***");
      FlutterRingtonePlayer.play(
          android: AndroidSounds.notification, ios: IosSounds.glass);
      onPressUpdate();
    });
  }

  void showPersonDialog(BuildContext context) {
    Widget personDialog = PersonDialog();
    showDialog(
        context: context, builder: (BuildContext context) => personDialog);
  }

  getLocationId() async {
    return await Firestore.instance
        .collection("users")
        .document(widget.userId)
        .collection("markers")
        .limit(1)
        .getDocuments()
        .then((QuerySnapshot b) => b.documents.first.documentID);
  }

  locationExists() async {
    return await Firestore.instance
        .collection("users")
        .document(widget.userId)
        .collection("markers")
        .limit(1)
        .getDocuments()
        .then((QuerySnapshot b) => b.documents.isEmpty ? false : true);
  }

  Future<Map<String, Marker>> getGroupMarkers(currentPosition) async {
    Map<String, Marker> markerList = {};

    var markers = await Firestore.instance
        .collectionGroup("markers")
        .getDocuments()
        .then((result) => result.documents);

    var fullMarkers = markers.forEach((snapshot) => markerList.addAll({
          snapshot.documentID: Marker(
              markerId: MarkerId(snapshot.documentID),
              icon: pinLocationIcon,
              position: LatLng(snapshot.data["position"].latitude,
                  snapshot.data["position"].longitude),
              infoWindow: InfoWindow(
                  title: snapshot.data["userName"],
                  snippet: "Informacoes adicionais ...",
                  onTap: () {
                    showPersonDialog(context);
                  }))
        }));

    return markerList;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (await locationExists()) {
      await updateGeoPoints(currentPosition);
    } else {
      createGeoPoints(currentPosition);
    }
    var loadedMarkers = await getGroupMarkers(currentPosition);

    setState(() {
      mapController = controller;
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 17.0)));
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }

  getCurrentUser() async {
    return await Firestore.instance
        .collection("users")
        .document(widget.userId)
        .get();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  void createGeoPoints(Position currentPosition) async {
    var currentUser = await getCurrentUser();

    Firestore.instance
        .collection("users")
        .document(widget.userId)
        .collection("markers")
        .add({
          "userName": capitalize(currentUser.data['fname']) +
              " " +
              capitalize(currentUser.data['surname']),
          "position":
              GeoPoint(currentPosition.latitude, currentPosition.longitude)
        })
        .then((result) => print("GEOPONTO ADICIONADO " + result.documentID))
        .catchError((error) => print("ERRO AO ADICIONAR GEOPONTO" + error));
  }

  Future updateGeoPoints(Position currentPosition) async {
    var locationId = await getLocationId();
    Firestore.instance
        .collection("users")
        .document(widget.userId)
        .collection("markers")
        .document(locationId)
        .updateData({
      "position": GeoPoint(currentPosition.latitude, currentPosition.longitude)
    });
    print("GEOPONTO ATUALIZADO");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mapa do Grupo'),
          backgroundColor: Colors.cyan,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers.values.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            Align(
              child: FloatingActionButton(
                child: Icon(Icons.update),
                backgroundColor: Colors.cyanAccent,
                onPressed: onPressUpdate,
              ),
              alignment: Alignment(0.8, 0.9),
            )
          ],
        ));
  }

  void onPressUpdate() async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (await locationExists()) {
      await updateGeoPoints(currentPosition);
    } else {
      createGeoPoints(currentPosition);
    }
    var loadedMarkers = await getGroupMarkers(currentPosition);

    setState(() {
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }
}

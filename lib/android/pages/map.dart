import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geograph/android/pages/person_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geograph/store/user/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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
  var locationHasBeenQueriedOnDataBase = false;
  var locationExistsOnDataBase = false;
  final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high, distanceFilter: 1, timeInterval: 5000);
  StreamSubscription<Position> positionSubscription;
  StreamSubscription<QuerySnapshot> refreshSubscription;
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
    refreshSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    setPositionEventsSubscription();
    setRefreshEventsSubscription();
  }

  void setRefreshEventsSubscription() {
    refreshSubscription = Firestore.instance
        .collectionGroup("markers")
        .snapshots()
        .listen((snapshot) {
      refreshChangedMarkers(snapshot);
    });
  }

  // This method is missing the logic to exclude the document of the self user,
  // since the above query does not exclude the document change of the user itself,
  // this logic should be implemented here. By the docs, there is no way to
  // exclude a document in a query, so every time the user location is updated,
  // this method is going to be triggered and the location of itself will be updated (again)
  void refreshChangedMarkers(QuerySnapshot snapshot) {
    Map<String, Marker> updatedMarkers = {};
    snapshot.documentChanges.forEach((documentChange) {
      var locationId = documentChange.document.documentID;
      var newLatitude = documentChange.document.data["position"].latitude;
      var newLongitude = documentChange.document.data["position"].longitude;
      var newMarker = _markers[locationId]
          .copyWith(positionParam: LatLng(newLatitude, newLongitude));
      updatedMarkers[locationId] = newMarker;
    });

    setState(() {
      updatedMarkers.forEach((String locationId, Marker newMarker) {
        _markers[locationId] = newMarker;
      });
    });
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
      updateGeoPointsAndRefreshSelfLocation(position);
    });
  }

  void showPersonDialog(BuildContext context) {
    Widget personDialog = PersonDialog();
    showDialog(
        context: context, builder: (BuildContext context) => personDialog);
  }

  Future<Map<String, Marker>> getGroupMarkers(currentPosition) async {
    Map<String, Marker> markerList = {};

    var markers = await Firestore.instance
        .collectionGroup("markers")
        .getDocuments()
        .then((result) => result.documents);

    markers.forEach((snapshot) => markerList.addAll({
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
    await createOrUpdateGeoPoint(currentPosition);
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

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tela de Grupo')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                              'https://scontent.fcgh10-1.fna.fbcdn.net/v/t1.0-9/95000440_1110826205943316_9215072197238849536_n.jpg?_nc_cat=101&_nc_sid=09cbfe&_nc_eui2=AeFZ_PUsfWSiLNJt80r7qnoKoDNo-8fk6Q2gM2j7x-TpDdAEvqKt-Rcrjlf0B-8-BG0Ov2Pq7lKRg4Vsa3UKTayw&_nc_ohc=LsycrnlcH1cAX_Df4q1&_nc_ht=scontent.fcgh10-1.fna&oh=2592e4bba2ae5f78b169e35d9ebfaa18&oe=5EEE2171'),
                          backgroundColor: Colors.transparent,
                        ),
                        Container(
                            padding: EdgeInsets.only(bottom: 10, left: 10),
                            child: Observer(
                              builder: (_) => Text(
                                "Nome do grupo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ],
                )),
            ListTile(
              leading: Icon(
                Icons.map,
                color: Theme.of(context).primaryColorDark,
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(userId: user.uid))),
              title: Text('Mostrar Mapa'),
            ),
            ListTile(
              leading: Icon(
                Icons.list,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('Mostrar Lista'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListPage())),
            ),
            Divider(
              height: 50,
              thickness: 2,
            ),
            ListTile(
              title: Text("Voltar para Menu"),
              leading: Icon(
                Icons.arrow_back,
                color: Theme.of(context).primaryColorDark,
              ),
              onTap: (){
                Navigator.pushReplacementNamed(context, "/home");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('FAQ'),
            ),
          ],
        ),
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
                backgroundColor: Theme.of(context).primaryColorDark,
                onPressed: onPressUpdate,
              ),
              alignment: Alignment(0.8, 0.9),
            )
          ],
        ),
    );

//    return Scaffold(
//        appBar: AppBar(
//          title: Text('Mapa do Grupo'),
//          backgroundColor: Theme.of(context).primaryColor,
//        ),
//        body: Stack(
//          children: <Widget>[
//            GoogleMap(
//              onMapCreated: _onMapCreated,
//              initialCameraPosition: CameraPosition(
//                target: _center,
//                zoom: 11.0,
//              ),
//              markers: _markers.values.toSet(),
//              myLocationEnabled: true,
//              myLocationButtonEnabled: true,
//            ),
//            Align(
//              child: FloatingActionButton(
//                child: Icon(Icons.update),
//                backgroundColor: Theme.of(context).primaryColorDark,
//                onPressed: onPressUpdate,
//              ),
//              alignment: Alignment(0.8, 0.9),
//            )
//          ],
//        ));
  }

  void onPressUpdate() async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    await createOrUpdateGeoPoint(currentPosition);
    var loadedMarkers = await getGroupMarkers(currentPosition);

    setState(() {
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }

  Future createOrUpdateGeoPoint(Position currentPosition) async {
    if (await geoPointsExists()) {
      await updateGeoPoints(currentPosition);
    } else {
      createGeoPoints(currentPosition);
    }
  }

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
        .then((result) => print("GEOPOINT CREATED " + result.documentID))
        .catchError((error) => print("ERROR WHILE CREATING GEOPOINT" + error));

    locationExistsOnDataBase = true;
  }

  Future updateGeoPoints(Position currentPosition) async {
    var locationId = await getLocationId();
    if (await geoPointsExists()) {
      Firestore.instance
          .collection("users")
          .document(widget.userId)
          .collection("markers")
          .document(locationId)
          .updateData({
        "position":
            GeoPoint(currentPosition.latitude, currentPosition.longitude)
      });
    }
    print("GEOPONTO ATUALIZADO");
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

  geoPointsExists() async {
    if (!locationHasBeenQueriedOnDataBase) {
      locationExistsOnDataBase = await Firestore.instance
          .collection("users")
          .document(widget.userId)
          .collection("markers")
          .limit(1)
          .getDocuments()
          .then((QuerySnapshot b) => b.documents.isEmpty ? false : true);
      locationHasBeenQueriedOnDataBase = true;
    }
    return locationExistsOnDataBase;
  }

  Future<void> updateGeoPointsAndRefreshSelfLocation(
      Position currentPosition) async {
    updateGeoPoints(currentPosition);
    var locationId = await getLocationId();
    refreshSelfLocation(currentPosition, locationId);
  }

  void refreshSelfLocation(Position currentPosition, String locationId) {
    var newMarker = _markers[locationId].copyWith(
        positionParam:
            LatLng(currentPosition.latitude, currentPosition.longitude));
    setState(() {
      _markers[locationId] = newMarker;
    });
  }
}

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GeoGraph')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                              'https://scontent.fcgh10-1.fna.fbcdn.net/v/t1.0-9/95000440_1110826205943316_9215072197238849536_n.jpg?_nc_cat=101&_nc_sid=09cbfe&_nc_eui2=AeFZ_PUsfWSiLNJt80r7qnoKoDNo-8fk6Q2gM2j7x-TpDdAEvqKt-Rcrjlf0B-8-BG0Ov2Pq7lKRg4Vsa3UKTayw&_nc_ohc=LsycrnlcH1cAX_Df4q1&_nc_ht=scontent.fcgh10-1.fna&oh=2592e4bba2ae5f78b169e35d9ebfaa18&oe=5EEE2171'),
                          backgroundColor: Colors.transparent,
                        ),
                        Container(
                            padding: EdgeInsets.only(bottom: 10, left: 10),
                            child: Observer(
                              builder: (_) => Text(
                                "Nome do grupo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ],
                )),
            ListTile(
              leading: Icon(
                Icons.map,
                color: Theme.of(context).primaryColorDark,
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(userId: user.uid))),
              title: Text('Mostrar Mapa'),
            ),
            ListTile(
              leading: Icon(
                Icons.list,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('Mostrar Lista'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListPage())),
            ),
            Divider(
              height: 50,
              thickness: 2,
            ),
            ListTile(
              title: Text("Exit Group"),
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).primaryColorDark,
              ),
              onTap: () => {"aasd"},
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('FAQ'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Text("Lista de membros"),
          Align(
            child: FloatingActionButton(
              child: Icon(Icons.update),
              backgroundColor: Theme.of(context).primaryColorDark,
              onPressed: () => { log("sdada")},
            ),
            alignment: Alignment(0.8, 0.9),
          )
        ],
      ),
    );
  }
}

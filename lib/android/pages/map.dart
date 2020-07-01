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
  MapPage({Key key, this.userId, this.groupId, this.membersArray})
      : super(key: key);
  final String userId;
  final String groupId;
  List<dynamic> membersArray;

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
  StreamSubscription<QuerySnapshot> usersSubscription;
  StreamSubscription<DocumentSnapshot> groupSubscription;
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
    usersSubscription.cancel();
    groupSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    setSelfPositionEventsSubscription();
    setGroupUsersPositionsEventsSubscription();
    setGroupChangesEventsSubscription();
  }

  void setGroupChangesEventsSubscription() {
    groupSubscription = Firestore.instance
        .collection("groups")
        .document(widget.groupId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) async {
      await groupChangeHandler(snapshot);
    });
  }

  void groupChangeHandler(DocumentSnapshot snapshot) async {
    var groupData = snapshot.data;
    List newMembersArray =
        groupData["members"].map((member) => member["uid"].documentID).toList();

    widget.membersArray = newMembersArray;
    updateGroupUsersPositionsEventsSubscription();
    var loadedMarkers = await getGroupMarkers();

    setState(() {
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }

  void updateGroupUsersPositionsEventsSubscription() {
    usersSubscription.cancel();
    setGroupUsersPositionsEventsSubscription();
  }

  void setGroupUsersPositionsEventsSubscription() {
    usersSubscription = Firestore.instance
        .collection("users")
        .where('uid', whereIn: widget.membersArray)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
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
    snapshot.documentChanges
        .where((element) => element.document.data["marker"] != null)
        .forEach((documentChange) {
      var locationId = documentChange.document.documentID;
      var newLatitude =
          documentChange.document.data["marker"]["position"].latitude;
      var newLongitude =
          documentChange.document.data["marker"]["position"].longitude;
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

  void setSelfPositionEventsSubscription() {
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

  Future<Map<String, Marker>> getGroupMarkers() async {
    Map<String, Marker> markerList = {};

    List<DocumentSnapshot> groupUsers = await Firestore.instance
        .collection("users")
        .where('uid', whereIn: widget.membersArray)
        .getDocuments()
        .then((result) => result.documents);

    groupUsers
        .where((element) => element.data["marker"] != null)
        .forEach((snapshot) {

          var userPositonLatitude = snapshot.data["marker"]["position"].latitude;
          var userPositonLongitude = snapshot.data["marker"]["position"].longitude;
          var userPosition = LatLng(userPositonLatitude, userPositonLongitude);
          var dialogTitle = snapshot.data["marker"]["userName"];

      markerList.addAll({
        snapshot.documentID: Marker(
            markerId: MarkerId(snapshot.documentID),
            icon: pinLocationIcon,
            position: userPosition,
            infoWindow: InfoWindow(
                title: dialogTitle,
                snippet: "Informacoes adicionais ...",
                onTap: () {
                  showPersonDialog(context);
                }))
      });
    });

    return markerList;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await createOrUpdateGeoPoint(currentPosition);
    var loadedMarkers = await getGroupMarkers();

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

  void onPressUpdate() async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    await createOrUpdateGeoPoint(currentPosition);
    var loadedMarkers = await getGroupMarkers();

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
        .updateData({
          "marker": {
            "userName": capitalize(currentUser.data['fname']) +
                " " +
                capitalize(currentUser.data['surname']),
            "position":
                GeoPoint(currentPosition.latitude, currentPosition.longitude)
          }
        })
        .then((result) => print("GEOPOINT CREATED "))
        .catchError((error) => print("ERROR WHILE CREATING GEOPOINT" + error));

    locationExistsOnDataBase = true;
  }

  Future updateGeoPoints(Position currentPosition) async {
    var currentUser = await getCurrentUser();
    var locationId = await getLocationId();
    if (await geoPointsExists()) {
      Firestore.instance
          .collection("users")
          .document(widget.userId)
          .updateData({
        "marker": {
          "position":
              GeoPoint(currentPosition.latitude, currentPosition.longitude),
          "userName": capitalize(currentUser.data['fname']) +
              " " +
              capitalize(currentUser.data['surname']),
        }
      });
    }
    print("GEOPONTO ATUALIZADO");
  }

  getLocationId() async {
    return await Firestore.instance
        .collection("users")
        .document(widget.userId)
        .get()
        .then((DocumentSnapshot document) => document.documentID);
  }

  geoPointsExists() async {
    if (!locationHasBeenQueriedOnDataBase) {
      locationExistsOnDataBase = await Firestore.instance
          .collection("users")
          .document(widget.userId)
          .get()
          .then((DocumentSnapshot document) =>
              document.data["marker"] != null ? true : false);
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

  void listenChange(QuerySnapshot snapshot) {
    log(snapshot.toString());
  }

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
                            'https://i.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI'),
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
                  context, MaterialPageRoute(builder: (context) => ListPage())),
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
              onTap: () {
                Navigator.pushReplacementNamed(context, "/home");
              },
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
//                onPressed: onPressUpdate,
              onPressed: () {
                log("Floating button click");
              },
            ),
            alignment: Alignment(0.8, 0.9),
          )
        ],
      ),
    );
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
                            'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y'),
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
                  context, MaterialPageRoute(builder: (context) => ListPage())),
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
              onPressed: () => {log("sdada")},
            ),
            alignment: Alignment(0.8, 0.9),
          )
        ],
      ),
    );
  }
}

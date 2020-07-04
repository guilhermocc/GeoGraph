import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geograph/android/pages/person_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geograph/main.dart';
import 'package:geograph/store/user/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  MapPage(
      {Key key,
      this.userId,
      this.groupId,
      this.membersUidList,
      this.membersList,
      this.viewType})
      : super(key: key);
  final String userId;
  final String groupId;
  String viewType;
  List<String> membersUidList;
  List<dynamic> membersList;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _center = LatLng(-23.563900, -46.653641);
  final Map<String, Marker> _markers = {};
  BitmapDescriptor pinLocationIconAdmin;
  BitmapDescriptor pinLocationIconNeutral;

  final geoLocator = Geolocator();
  var locationHasBeenQueriedOnDataBase = false;
  var locationExistsOnDataBase = false;
  final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high, distanceFilter: 1, timeInterval: 5000);
  StreamSubscription<Position> positionSubscription;
  StreamSubscription<QuerySnapshot> usersSubscription;
  StreamSubscription<DocumentSnapshot> groupSubscription;
  GoogleMapController mapController;
  String userType;
  final Map<String, dynamic> groupMembersInfos = {};
  LatLng currentUserPosition;

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
    loadGroupMembersInfos();
    loadInitialMarkers();
    loadFirstCurrentPosition();
    setUserType();
    setCustomMapPin();
    setSelfPositionEventsSubscription();
    setGroupUsersPositionsEventsSubscription();
    setGroupChangesEventsSubscription();
  }

  void loadFirstCurrentPosition() async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentUserPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);
    });
  }

  void loadInitialMarkers() async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await createOrUpdateGeoPoint(currentPosition);
    var loadedMarkers = await getGroupMarkers();
    setState(() {
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }

  void loadGroupMembersInfos() async {
    Map<String, dynamic> updatedGroupMembers = {};

    List<DocumentSnapshot> groupUsers = await Firestore.instance
        .collection("users")
        .where('uid', whereIn: widget.membersUidList)
        .getDocuments()
        .then((result) => result.documents);

    groupUsers
        .where((element) => element.data["marker"] != null)
        .forEach((snapshot) {
      var userData = snapshot.data;
      updatedGroupMembers.addAll({
        userData["uid"]: {
          "uid": userData["uid"],
          "email": userData["email"],
          "fullname": userData["fname"] + " " + userData["surname"],
          "type": widget.membersList.firstWhere(
              (element) => element["uid"].documentID == userData["uid"])["type"]
        }
      });
    });

    setState(() {
      groupMembersInfos.clear();
      groupMembersInfos.addAll(updatedGroupMembers);
    });
  }

  void setGroupChangesEventsSubscription() {
    groupSubscription = Firestore.instance
        .collection("groups")
        .document(widget.groupId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) async {
      groupChangeHandler(snapshot);
    });
  }

  void groupChangeHandler(DocumentSnapshot snapshot) async {
    var groupData = snapshot.data;
    List<String> newMembersUidList = new List<String>.from(groupData["members"]
        .map((member) => member["uid"].documentID)
        .toList());

    List newMembersList = groupData["members"];

    widget.membersUidList = newMembersUidList;
    widget.membersList = newMembersList;

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
        .where('uid', whereIn: widget.membersUidList)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      refreshChangedMarkers(snapshot);
      refreshMembersInfos(snapshot);
    });
  }

  void refreshMembersInfos(QuerySnapshot snapshot) {
    Map<String, dynamic> updatedMemberInfos = {};
    snapshot.documentChanges
        .where((element) => element.document.data["marker"] != null)
        .forEach((documentChange) {
      var userData = documentChange.document.data;
      updatedMemberInfos.addAll({
        userData["uid"]: {
          "uid": userData["uid"],
          "email": userData["email"],
          "fullname": userData["fname"] + " " + userData["surname"],
          "type": widget.membersList.firstWhere(
              (element) => element["uid"].documentID == userData["uid"])["type"]
        }
      });
    });
    setState(() {
      updatedMemberInfos.forEach((String userId, dynamic info) {
        groupMembersInfos[userId] = info;
      });
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
      // A lot of errors are being raised here when markers are null
      InfoWindow infoWindowOld = _markers[locationId].infoWindow;
      InfoWindow newInfoWindow = InfoWindow(
          title: infoWindowOld.title,
          snippet: Haversine.formatedDistance(currentUserPosition.latitude,
              currentUserPosition.longitude, newLatitude, newLongitude),
          onTap: infoWindowOld.onTap);
      var newMarker = _markers[locationId].copyWith(
          positionParam: LatLng(newLatitude, newLongitude),
          infoWindowParam: newInfoWindow);
      updatedMarkers[locationId] = newMarker;
    });

    setState(() {
      updatedMarkers.forEach((String locationId, Marker newMarker) {
        _markers[locationId] = newMarker;
      });
    });
  }

  void setCustomMapPin() async {
    pinLocationIconNeutral = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/neutral_user.png');
    pinLocationIconAdmin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/admin_user.png');
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

  void showPersonDialog(BuildContext context, Placemark placemark,
      String formatedDistance, String username) {
    Widget personDialog = PersonDialog(
      placemark: placemark,
      username: username,
      formatedDistance: formatedDistance,
    );
    showDialog(
        context: context, builder: (BuildContext context) => personDialog);
  }

  Future<Map<String, Marker>> getGroupMarkers() async {
    Map<String, Marker> markerList = {};

    List<DocumentSnapshot> groupUsers = await Firestore.instance
        .collection("users")
        .where('uid', whereIn: widget.membersUidList)
        .getDocuments()
        .then((result) => result.documents);

    List<Future<Map<String, Marker>>> markersFutures = groupUsers
        .where((element) => element.data["marker"] != null)
        .map((snapshot) async {
      var memberPositonLatitude = snapshot.data["marker"]["position"].latitude;
      var memberPositonLongitude =
          snapshot.data["marker"]["position"].longitude;
      var memberPosition =
          LatLng(memberPositonLatitude, memberPositonLongitude);
      var dialogTitle = snapshot.data["marker"]["userName"];

      List<Placemark> placemarList = await Geolocator()
          .placemarkFromCoordinates(
              memberPositonLatitude, memberPositonLongitude,
              localeIdentifier: "pt-br");

      Placemark placemark = placemarList.first;
      String formatedDistance = Haversine.formatedDistance(
          currentUserPosition.latitude,
          currentUserPosition.longitude,
          memberPosition.latitude,
          memberPosition.longitude);

      return {
        snapshot.documentID: Marker(
            markerId: MarkerId(snapshot.documentID),
            icon: pinLocationIconNeutral,
            position: memberPosition,
            infoWindow: InfoWindow(
                title: dialogTitle,
                snippet: "${placemark.thoroughfare} - ${formatedDistance}",
                onTap: () {
                  showPersonDialog(context, placemark, formatedDistance,
                      snapshot.data["marker"]["userName"]);
                }))
      };
    }).toList();

    List<Map<String, Marker>> markers = await Future.wait(markersFutures);
    markers.forEach((element) {
      markerList.addAll(element);
    });
    return markerList;
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    Position currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      mapController = controller;
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 17.0)));
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
    var locationId = widget.userId;
    refreshSelfLocation(currentPosition, locationId);
    setState(() {
      currentUserPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);
    });
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
    print(snapshot.toString());
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tela do Grupo')),
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
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                          userId: user.uid,
                          groupId: widget.groupId,
                          membersUidList: widget.membersUidList,
                          membersList: widget.membersList))),
              title: Text('Mostrar Mapa'),
            ),
            ListTile(
              leading: Icon(
                Icons.list,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('Mostrar Lista'),
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            userId: user.uid,
                            groupId: widget.groupId,
                            membersUidList: widget.membersUidList,
                            membersList: widget.membersList,
                            viewType: "list",
                          ))),
            ),
            userType == "admin"
                ? ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    title: Text('Alterar informações de grupo'),
                    onTap: () => print("sadasd"),
                  )
                : Container(),
            userType == "admin"
                ? ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    title: Text('Encerrar Grupo'),
                    onTap: () => print("sadasd"),
                  )
                : Container(),
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
      body: widget.viewType == null
          ? Stack(
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
                      print(_markers[0].toString());
                    },
                  ),
                  alignment: Alignment(0.8, 0.9),
                )
              ],
            )
          : ListView(
              children: listOfUserCards(),
            ),
    );
  }

  List<Widget> listOfUserCards() {
    List<Card> cardsList = [];
    groupMembersInfos.forEach((uid, info) async {
      String memberType = info["type"];
      LatLng memberPosition = _markers[uid].position;
      String formatedDistance = Haversine.formatedDistance(
          currentUserPosition.latitude,
          currentUserPosition.longitude,
          memberPosition.latitude,
          memberPosition.longitude);
      cardsList.add(Card(
        child: ListTile(
          leading: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y'),
                backgroundColor: Colors.transparent,
              ),
              Padding(padding: EdgeInsets.only(top: 0.0)),
              (memberType == "admin") ? Text("Admin") : SizedBox()
            ],
          ),
          title: Text(info["fullname"]),
          subtitle: Text(formatedDistance),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColorDark,
          ),
          onTap: () => print("sdfsdf"),
        ),
      ));
    });
    return cardsList;
  }

  void setUserType() {
    var userMember = widget.membersList
        .firstWhere((member) => member["uid"].documentID == widget.userId);
    setState(() {
      userType = userMember["type"];
    });
  }
}

class Haversine {
  static final R = 6372.8; // In kilometers

  static double haversine(double lat1, lon1, lat2, lon2) {
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);
    double a =
        pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
    double c = 2 * asin(sqrt(a));
    return R * c;
  }

  static String formatedDistance(double lat1, lon1, lat2, lon2) {
    String result = "";
    double distanceInKilometers = haversine(lat1, lon1, lat2, lon2);
    double distanceInMeters = distanceInKilometers * 1000;
    double distanceInCentimeters = distanceInMeters * 100;
    if (distanceInKilometers < 1.0) {
      if (distanceInMeters < 1.0) {
        return (distanceInCentimeters).toStringAsFixed(0) + " cm";
      }
      return (distanceInMeters).toStringAsFixed(2) + " m";
    }
    return distanceInKilometers.toStringAsFixed(2) + " km";
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}

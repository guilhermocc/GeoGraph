import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geograph/android/pages/delete_group_dialog.dart';
import 'package:geograph/android/pages/exit_group_dialog.dart';
import 'package:geograph/android/pages/group_update_page.dart';
import 'package:geograph/android/pages/person_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geograph/store/user/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'dart:math';

import 'group_info_page.dart';

class MapPage extends StatefulWidget {
  MapPage(
      {Key key,
      this.userId,
      this.groupId,
      this.groupTitle,
      this.groupDescription,
      this.membersUidList,
      this.membersList,
      this.viewType})
      : super(key: key);
  final String userId;
  final String groupId;
  final String groupTitle;
  final String groupDescription;
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
  bool onlyOneAdmin = true;
  String groupTitle;
  String groupDescription;

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
    loadFirstCurrentPosition();
    setInitiaGroupInfo();
    setOnlyOneAdminStatus();
    loadGroupMembersInfos();
    loadInitialMarkers();
    setUserType();
    setCustomMapPin();
    setSelfPositionEventsSubscription();
    setGroupUsersPositionsEventsSubscription();
    setGroupChangesEventsSubscription();
  }

  void setInitiaGroupInfo() {
    setState(() {
      groupDescription = widget.groupDescription;
      groupTitle = widget.groupTitle;
    });
  }

  void setOnlyOneAdminStatus() {
    int adminsNumber = widget.membersList
        .where((element) => element["type"] == "admin")
        .length;
    setState(() {
      onlyOneAdmin = adminsNumber == 1 ? true : false;
    });
  }

  void loadFirstCurrentPosition() async {
    Position currentPosition = await getCurrentPositionOrLast();
    setState(() {
      currentUserPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);
    });
  }

  void loadInitialMarkers() async {
    Position currentPosition = await getCurrentPositionOrLast();
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

    Iterable<Future<Map<dynamic, Map<String, dynamic>>>>
        updatedGroupMembersFutures = groupUsers
            .where((element) => element.data["marker"] != null)
            .map((snapshot) async {
      var userData = snapshot.data;

      List<Placemark> placemarList = await makeGeoCoding(
          userData['marker']['position'].latitude,
          userData['marker']["position"].longitude);

      Placemark placemark = placemarList.first;

      return {
        userData["uid"]: {
          "uid": userData["uid"],
          "email": userData["email"],
          "fullname": userData["fname"] + " " + userData["surname"],
          "type": widget.membersList.firstWhere((element) =>
              element["uid"].documentID == userData["uid"])["type"],
          "thoroughfare": placemark.thoroughfare,
          "placemark": placemark
        }
      };
    });

    List<Map<dynamic, Map<String, dynamic>>> updatedGroupMembersFuturesList =
        await Future.wait(updatedGroupMembersFutures);

    updatedGroupMembersFuturesList.forEach((e) {
      String key = e.keys.first;
      dynamic value = e.values.first;
      updatedGroupMembers.addAll({key: value});
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
      await checkGroupRemovalOrDelete(snapshot);
      groupChangeHandler(snapshot);
      checkUserTypeChanged(snapshot);
      updateGroupInfo(snapshot);
    });
  }

  void updateGroupInfo(DocumentSnapshot snapshot) {
    if (groupDescription != snapshot.data["description"] ||
        groupTitle != snapshot.data["title"])
      setState(() {
        groupTitle = snapshot.data["title"];
        groupDescription = snapshot.data["description"];
      });
  }

  void checkUserTypeChanged(DocumentSnapshot snapshot) async {
    var groupData = snapshot.data;

    var userMember = groupData["members"]
        .firstWhere((member) => member["uid"].documentID == widget.userId);

    setState(() {
      userType = userMember["type"];
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

    int adminsNumber = widget.membersList
        .where((element) => element["type"] == "admin")
        .length;

    updateGroupUsersPositionsEventsSubscription();
    var loadedMarkers = await getGroupMarkers();

    setState(() {
      _markers.clear();
      _markers.addAll(loadedMarkers);
      onlyOneAdmin = adminsNumber == 1 ? true : false;
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

  Future<bool> checkGroupRemovalOrDelete(DocumentSnapshot snapshot) async {
    bool groupExists = snapshot.exists;
    if (!groupExists) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  height: 300.0,
                  width: 300.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Este grupo não existe mais.",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, "/home");
                              },
                              child: Text(
                                'Fechar',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
      dispose();
      Navigator.pushReplacementNamed(context, "/home");
      return false;
    } else {
      List<dynamic> groupMembers = snapshot.data["members"];
      bool userDeleted = !groupMembers
          .any((element) => element["uid"].documentID == widget.userId);
      if (userDeleted) {
        await showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    height: 300.0,
                    width: 300.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Você não faz mais parte deste grupo",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, "/home");
                                },
                                child: Text(
                                  'Fechar',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
        dispose();
        Navigator.pushReplacementNamed(context, "/home");
        return false;
      }
      return true;
    }
  }

  void refreshMembersInfos(QuerySnapshot snapshot) async {
    Map<String, dynamic> updatedMemberInfos = {};
    Iterable<Future<Map<dynamic, Map<String, dynamic>>>>
        updatedMemberInfosFutures = snapshot.documentChanges
            .where((element) => element.document.data["marker"] != null)
            .map((documentChange) async {
      var userData = documentChange.document.data;
      List<Placemark> placemarList = await makeGeoCoding(
          userData["marker"]["position"].latitude,
          userData["marker"]["position"].longitude);

      Placemark placemark = placemarList.first;

      return {
        userData["uid"]: {
          "uid": userData["uid"],
          "email": userData["email"],
          "fullname": userData["fname"] + " " + userData["surname"],
          "type": widget.membersList.firstWhere((element) =>
              element["uid"].documentID == userData["uid"])["type"],
          "thoroughfare": placemark.thoroughfare,
          "placemark": placemark
        }
      };
    });

    List<Map<dynamic, Map<String, dynamic>>> updatedGroupMembersFuturesList =
        await Future.wait(updatedMemberInfosFutures);

    updatedGroupMembersFuturesList.forEach((e) {
      String key = e.keys.first;
      dynamic value = e.values.first;
      updatedMemberInfos.addAll({key: value});
    });

    setState(() {
      updatedMemberInfos.forEach((String userId, dynamic info) {
        groupMembersInfos[userId] = info;
      });
    });
  }

  Future<List<Placemark>> makeGeoCoding(latitude, longitude) async {
    try {
      List<Placemark> geolocatorGeocoding = await Geolocator()
          .placemarkFromCoordinates(latitude, longitude,
              localeIdentifier: "pt-br");

      return geolocatorGeocoding;
    } catch (Exception) {
      return [
        Placemark(
            thoroughfare: "",
            administrativeArea: "",
            subAdministrativeArea: "",
            country: "",
            subLocality: "",
            subThoroughfare: "")
      ];
    }
  }

  // This method is missing the logic to exclude the document of the self user,
  // since the above query does not exclude the document change of the user itself,
  // this logic should be implemented here. By the docs, there is no way to
  // exclude a document in a query, so every time the user location is updated,
  // this method is going to be triggered and the location of itself will be updated (again)
  Future<void> refreshChangedMarkers(QuerySnapshot snapshot) async {
    Map<String, Marker> updatedMarkers = {};
    Iterable<Future<Map<String, Marker>>> updatedMarkersFutures = snapshot
        .documentChanges
        .where((element) =>
            _markers[element.document.documentID] != null &&
            element.document.data["marker"] != null &&
            (element.document.data["marker"]["position"].longitude != 0.0 ||
                element.document.data["marker"]["position"].longitude != 0.0))
        .map((documentChange) async {
      var locationId = documentChange.document.documentID;

      var newLatitude =
          documentChange.document.data["marker"]["position"].latitude;
      var newLongitude =
          documentChange.document.data["marker"]["position"].longitude;

      List<Placemark> placemarList =
          await makeGeoCoding(newLatitude, newLongitude);
      Placemark placemark = placemarList.first;

      String formattedDistance = Haversine.formattedDistance(
          currentUserPosition.latitude,
          currentUserPosition.longitude,
          newLatitude,
          newLongitude);

      String memberType = groupMembersInfos[locationId]["type"];

      // A lot of errors are being raised here when markers are null
      InfoWindow infoWindowOld = _markers[locationId].infoWindow;
      InfoWindow newInfoWindow = InfoWindow(
          title: capitalize(documentChange.document.data['fname']) +
              " " +
              capitalize(documentChange.document.data['surname']),
          snippet: (placemark.thoroughfare == "")
              ? formattedDistance
              : "${placemark.thoroughfare} - $formattedDistance",
          onTap: () => showPersonDialog(
              context,
              placemark,
              formattedDistance,
              capitalize(documentChange.document.data['fname']) +
                  " " +
                  capitalize(documentChange.document.data['surname']),
              documentChange.document.documentID,
              memberType,
              true));

      var newMarker = _markers[locationId].copyWith(
          positionParam: LatLng(newLatitude, newLongitude),
          infoWindowParam: newInfoWindow,
          iconParam: memberType == "admin"
              ? pinLocationIconAdmin
              : pinLocationIconNeutral);
      return {locationId: newMarker};
    });

    List<Map<String, Marker>> updatedMarkersList =
        await Future.wait(updatedMarkersFutures);
    updatedMarkersList.forEach((element) {
      String key = element.keys.first;
      Marker value = element.values.first;
      updatedMarkers.addAll({key: value});
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

  Future<void> setSelfPositionEventsSubscription() async {
    try {
      GeolocationStatus permissionStatus =
          await Geolocator().checkGeolocationPermissionStatus();
      if (permissionStatus.toString() == "GeolocationStatus.granted")
        positionSubscription = geoLocator
            .getPositionStream(locationOptions)
            .listen((Position position) {
          print("*** GEOLOCATION UPDATE EVENT FIRED ***");
          updateGeoPointsAndRefreshSelfLocation(position);
        });
    } catch (PlatformException) {
      return null;
    }
  }

  void showPersonDialog(
      BuildContext context,
      Placemark placemark,
      String formatedDistance,
      String username,
      String memberUid,
      String memberType,
      bool positionIsValid) {
    Widget personDialog = PersonDialog(
      placemark: placemark,
      username: username,
      formatedDistance: formatedDistance,
      memberUid: memberUid,
      groupUid: widget.groupId,
      controllerUserType: userType,
      memberType: memberType,
      controllerUserUid: widget.userId,
      positionValid: positionIsValid,
    );
    showDialog(
        context: context, builder: (BuildContext context) => personDialog);
  }

  void showExitGroupDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ExitGroupDialog(
            memberUid: widget.userId, groupUid: widget.groupId));
  }

  void showDeleteGroupDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => DeleteGroupDialog(
            memberUid: widget.userId, groupUid: widget.groupId));
  }

  void generateInvite(BuildContext context) {
    Share.share('Entre no grupo de compartilhamento de geolocalização :) https://GeoGraphTourism.com.br/${widget.groupId}');
  }

  Future<Map<String, Marker>> getGroupMarkers() async {
    Map<String, Marker> markerList = {};

    List<DocumentSnapshot> groupUsers = await Firestore.instance
        .collection("users")
        .where('uid', whereIn: widget.membersUidList)
        .getDocuments()
        .then((result) => result.documents);

    List<Future<Map<String, Marker>>> markersFutures = groupUsers
        .where((element) =>
            element.data["marker"] != null &&
            (element.data["marker"]["position"].latitude != 0 ||
                element.data["marker"]["position"].longitude != 0))
        .map((snapshot) async {
      var memberPositonLatitude = snapshot.data["marker"]["position"].latitude;
      var memberPositonLongitude =
          snapshot.data["marker"]["position"].longitude;
      var memberPosition =
          LatLng(memberPositonLatitude, memberPositonLongitude);
      var dialogTitle = snapshot.data["fname"] + " " + snapshot.data["surname"];

      List<Placemark> placemarList =
          await makeGeoCoding(memberPositonLatitude, memberPositonLongitude);

      Placemark placemark = placemarList.first;
      String formattedDistance = Haversine.formattedDistance(
          currentUserPosition.latitude,
          currentUserPosition.longitude,
          memberPosition.latitude,
          memberPosition.longitude);

      String memberType = groupMembersInfos[snapshot.documentID]["type"];

      return {
        snapshot.documentID: Marker(
            markerId: MarkerId(snapshot.documentID),
            icon: memberType == "admin"
                ? pinLocationIconAdmin
                : pinLocationIconNeutral,
            position: memberPosition,
            infoWindow: InfoWindow(
                title: dialogTitle,
                snippet: (placemark.thoroughfare == "")
                    ? "$formattedDistance"
                    : "${placemark.thoroughfare} - $formattedDistance",
                onTap: () {
                  showPersonDialog(
                      context,
                      placemark,
                      formattedDistance,
                      capitalize(snapshot.data['fname']) +
                          " " +
                          capitalize(snapshot.data['surname']),
                      snapshot.documentID,
                      memberType,
                      true);
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
    Position currentPosition = await getCurrentPositionOrLast();

    setState(() {
      mapController = controller;
      // Quando for posicao invalida animar para o meio do brasil
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: currentPosition.latitude != 0.0 ||
                  currentPosition.longitude != 0.0
              ? LatLng(currentPosition.latitude, currentPosition.longitude)
              : LatLng(-23.563210, -46.654251),
          zoom: currentPosition.latitude != 0.0 ||
                  currentPosition.longitude != 0.0
              ? 15.0
              : 10.0)));
    });
  }

  Future<Position> getCurrentPositionOrLast() async {
    GeolocationStatus permissionStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (permissionStatus.toString() == "GeolocationStatus.granted" &&
        await Geolocator().isLocationServiceEnabled()) {
      return await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } else {
      try {
        if (permissionStatus.toString() == "GeolocationStatus.granted") {
          var lastKnownPosition = await Geolocator().getLastKnownPosition();
          if (lastKnownPosition == null) {
            DocumentSnapshot userSnapShot = await Firestore.instance
                .collection("users")
                .document(widget.userId)
                .get();
            GeoPoint geopoint = userSnapShot.data["marker"]["position"];
            return Position(
                latitude: geopoint.latitude, longitude: geopoint.longitude);
          } else {
            return lastKnownPosition;
          }
        } else {
          DocumentSnapshot userSnapShot = await Firestore.instance
              .collection("users")
              .document(widget.userId)
              .get();
          GeoPoint geopoint = userSnapShot.data["marker"]["position"];
          return Position(
              latitude: geopoint.latitude, longitude: geopoint.longitude);
        }
      } catch (Exception) {
        DocumentSnapshot userSnapShot = await Firestore.instance
            .collection("users")
            .document(widget.userId)
            .get();
        GeoPoint geopoint = userSnapShot.data["marker"]["position"];
        return Position(
            latitude: geopoint.latitude, longitude: geopoint.longitude);
      }
    }
  }

  getCurrentUser() async {
    return await Firestore.instance
        .collection("users")
        .document(widget.userId)
        .get();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
              GeoPoint(currentPosition.latitude, currentPosition.longitude)
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
    if (_markers[locationId] != null) {
      var newMarker = _markers[locationId].copyWith(
          positionParam:
              LatLng(currentPosition.latitude, currentPosition.longitude));
      setState(() {
        _markers[locationId] = newMarker;
      });
    }
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
                          backgroundImage: AssetImage('assets/groups.jpg'),
                          backgroundColor: Colors.transparent,
                        ),
                        Container(
                            padding: EdgeInsets.only(bottom: 10, left: 10),
                            child: Observer(
                              builder: (_) => Text(
                                capitalize(groupTitle),
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
                          groupDescription: groupDescription,
                          groupTitle: groupTitle,
                          membersUidList: widget.membersUidList,
                          membersList: widget.membersList))),
              title: Text('Mapa Interativo'),
            ),
            ListTile(
              leading: Icon(
                Icons.list,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('Lista de Membros'),
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            userId: user.uid,
                            groupId: widget.groupId,
                            groupDescription: groupDescription,
                            groupTitle: groupTitle,
                            membersUidList: widget.membersUidList,
                            membersList: widget.membersList,
                            viewType: "list",
                          ))),
            ),
            ListTile(
              leading: Icon(
                Icons.remove_red_eye,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('Informações do grupo'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupInfoPage(
                            groupId: widget.groupId,
                            userType: userType,
                          ))),
            ),
            userType == "admin"
                ? ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    title: Text('Alterar informações de grupo'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupUpdatePage(
                                  groupId: widget.groupId,
                                  userType: userType,
                                ))),
                  )
                : Container(),
            ListTile(
              leading: Icon(
                Icons.share,
                color: Theme.of(context).primaryColorDark,
              ),
              title: Text('Gerar Convite'),
              onTap: () => generateInvite(context),
            ),
            userType == "admin"
                ? ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    title: Text('Encerrar Grupo'),
                    onTap: () => showDeleteGroupDialog(context),
                  )
                : Container(),
            (!onlyOneAdmin || userType != "admin")
                ? ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    title: Text('Sair do grupo'),
                    onTap: () {
                      showExitGroupDialog(context);
                    },
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
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/home', (Route r) => r == null);
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
              ],
            )
          : ListView(
              children: listOfUserCards(),
            ),
    );
  }

  List<Widget> listOfUserCards() {
    List<Card> cardsList = [];
    int personCount = 2;
    groupMembersInfos.forEach((uid, info) async {
      print(personCount);
      String memberType = info["type"];
      String thoroughfare = info["thoroughfare"];
      if (_markers[uid] == null) {
        cardsList.add(buildUserCard(memberType, personCount, info, thoroughfare,
            false, "", uid, false));
      } else {
        LatLng memberPosition = _markers[uid].position;
        bool userDontHavePosition =
            memberPosition.latitude == 0.0 && memberPosition.longitude == 0.0;
        String formattedDistance = Haversine.formattedDistance(
            currentUserPosition.latitude,
            currentUserPosition.longitude,
            memberPosition.latitude,
            memberPosition.longitude);
        cardsList.add(buildUserCard(memberType, personCount, info, thoroughfare,
            userDontHavePosition, formattedDistance, uid, true));
        personCount = (personCount == 12) ? 2 : personCount + 1;
      }
    });
    return cardsList;
  }

  Card buildUserCard(
      String memberType,
      int personCount,
      info,
      String thoroughfare,
      bool userDontHavePosition,
      String formattedDistance,
      String uid,
      bool hasInfo) {
    return Card(
      color: (memberType == "admin")
          ? Theme.of(context).primaryColor
          : Colors.white,
      child: ListTile(
        leading: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/person_$personCount.jpg'),
              backgroundColor: Colors.transparent,
            ),
            Padding(padding: EdgeInsets.only(top: 0.0)),
            (memberType == "admin")
                ? Text("Guia", style: TextStyle(color: Colors.white))
                : SizedBox()
          ],
        ),
        title: Text(
          info["fullname"],
          style: (memberType == "admin")
              ? TextStyle(color: Colors.white)
              : TextStyle(color: Colors.black),
        ),
        subtitle: hasInfo
            ? Text(
                (thoroughfare == "")
                    ? (userDontHavePosition) ? "" : "$formattedDistance"
                    : "$thoroughfare - $formattedDistance",
                style: (memberType == "admin")
                    ? TextStyle(color: Colors.white)
                    : TextStyle(color: Colors.black))
            : Text(
                "Sem informações disponíveis",
                style: (memberType == "admin")
                    ? TextStyle(color: Colors.white)
                    : TextStyle(color: Colors.black),
              ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: (memberType == "admin")
              ? Colors.white
              : Theme.of(context).primaryColorDark,
        ),
        onTap: () => showPersonDialog(
            context,
            info["placemark"],
            formattedDistance,
            info["fullname"],
            uid,
            memberType,
            !userDontHavePosition),
      ),
    );
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

  static String formattedDistance(double lat1, lon1, lat2, lon2) {
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

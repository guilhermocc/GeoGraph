import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/custom_person.png');
  }

  GoogleMapController mapController;


  void showSimpleCustomDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
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
              child: Text(
                'Caixa de informacoes do cliente',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Notificar Cliente',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Fechar',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }


  getLocationId() async{
    return await Firestore.instance.collection("users").document(widget.userId).collection("markers").limit(1).getDocuments()
    .then((QuerySnapshot b) => b.documents.first.documentID);
  }

   locationExists() async{
    return await Firestore.instance.collection("users").document(widget.userId).collection("markers").limit(1).getDocuments()
        .then((QuerySnapshot b) => b.documents.isEmpty? false: true);
  }

  Future<Map<String, Marker>>getGroupMarkers(currentPosition) async{
    Map<String, Marker> markerList = {};

    var markers = await Firestore.instance.collectionGroup("markers").getDocuments()
    .then((result) => result.documents);

    var fullMarkers = markers.forEach((snapshot) =>  markerList.addAll({
      snapshot.documentID
          : Marker(
          markerId: MarkerId(snapshot.documentID),
          icon: pinLocationIcon,
          position: LatLng(snapshot.data["position"].latitude, snapshot.data["position"].longitude),
          infoWindow: InfoWindow(
              title: "Nome da Pessoa",
              snippet: "Informacoes da pessoa",
              onTap: () {
                showSimpleCustomDialog(context);
              }
          )
      )
    }));

    return markerList;
  }

   Future<void>_onMapCreated(GoogleMapController controller) async{
    Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (await locationExists()){
      await updateGeoPoints(currentPosition);
    }
    else {
      createGeoPoints(currentPosition);
    }
    var loadedMarkers = await getGroupMarkers(currentPosition);


    setState(() {
      mapController = controller;
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 17.0
        )
      ));
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }

   void createGeoPoints(Position currentPosition) {
     Firestore.instance
         .collection("users")
         .document(widget.userId)
         .collection("markers")
         .add({
           "position": GeoPoint(currentPosition.latitude, currentPosition.longitude)
          })
         .then((result) => print("GEOPONTO ADICIONADO " + result.documentID ))
         .catchError((error) => print("ERRO AO ADICIONAR GEOPONTO"+ error));
   }

   Future updateGeoPoints(Position currentPosition) async {
       var locationId = await getLocationId();
     Firestore.instance
         .collection("users")
         .document(widget.userId)
         .collection("markers")
         .document(locationId)
         .updateData(
       {
         "position": GeoPoint(currentPosition.latitude, currentPosition.longitude)
       }
     );
     print("GEOPONTO ATUALIZADO");
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Map'),
        backgroundColor: Colors.lightGreen,
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
                child: Icon(Icons.file_upload),
                backgroundColor: Colors.green,
                onPressed: onPressUpdate,
              ),
            alignment: Alignment(0.8, 0.9),
          )


        ],
      )

    );




  }

  void onPressUpdate() async{
    Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (await locationExists()){
    await updateGeoPoints(currentPosition);
    }
    else {
    createGeoPoints(currentPosition);
    }
    var loadedMarkers = await getGroupMarkers(currentPosition);


    setState(() {
    _markers.clear();
    _markers.addAll(loadedMarkers);
    });

  }


}


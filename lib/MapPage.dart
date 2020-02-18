import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng _center = LatLng(-23.563900, -46.653641);
  final Map<String, Marker> _markers = {};

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
                'Simple dialog showing client info',
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
                      'Notify client',
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
                      'Close',
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

   Future<void>_onMapCreated(GoogleMapController controller) async{
    Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      mapController = controller;
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 17.0
        )
      ));
      _markers.clear();
      _markers["first"] = Marker(
          markerId: MarkerId("first"),
          icon: BitmapDescriptor.defaultMarkerWithHue(00.00),
          position: LatLng(currentPosition.latitude, currentPosition.longitude),
          infoWindow: InfoWindow(
              title: "Guilherme Oliveira",
              snippet: "Information snippet",
              onTap: () {
                showSimpleCustomDialog(context);
              }
          )
      );

      _markers["second"] = Marker(
          markerId: MarkerId("second"),
          icon: BitmapDescriptor.defaultMarkerWithHue(300.00),
          position: LatLng(currentPosition.latitude - 0.0005, currentPosition.longitude - 0.0011),
          infoWindow: InfoWindow(
              title: "Beltrano Pereira",
              snippet: "Information snippet",
              onTap: () {
                showSimpleCustomDialog(context);
              }
          )
      );

      _markers["third"] = Marker(
          markerId: MarkerId("third"),
          icon: BitmapDescriptor.defaultMarkerWithHue(100.00),
          position: LatLng(currentPosition.latitude + 0.0005, currentPosition.longitude + 0.008),
          infoWindow: InfoWindow(
              title: "Fulano Almeida",
              snippet: "Information snippet",
              onTap: () {
                showSimpleCustomDialog(context);
              }
          )
      );

      _markers["fourth"] = Marker(
          markerId: MarkerId("fourth"),
          icon: BitmapDescriptor.defaultMarkerWithHue(200.00),
          position: LatLng(currentPosition.latitude + 0.0009, currentPosition.longitude - 0.0004),
          infoWindow: InfoWindow(
              title: "Ciclano Carvalho",
              snippet: "Information snippet",
              onTap: () {
                showSimpleCustomDialog(context);
              }
          )
      );



    });
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
        ],
      )

    );


  }


}


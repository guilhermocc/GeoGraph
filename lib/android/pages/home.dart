import 'package:geograph/android/pages/map.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid}) : super(key: key);
  final String title;
  final String uid;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position myLocation;
  List<Placemark> myPlacemark;

  Future<void> _onGetMyLocation() async {
    Position currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude,
        localeIdentifier: "en");
    setState(() {
      myLocation = currentLocation;
      myPlacemark = placemark;
    });
  }

  void _onLogout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/splash");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _onLogout,
          )
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              child: Text("Mostrar meu mapa"),
              color: Colors.cyanAccent,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapPage(
                              userId: widget.uid,
                            )));
              },
            ),
            MaterialButton(
              child: Text("Captar minha localizacao"),
              color: Colors.cyanAccent,
              onPressed: () {
                _onGetMyLocation();
              },
            ),
            (myLocation != null
                ? Column(
                    children: <Widget>[
                      Text(
                          "Latitude: ${myLocation.latitude}, Longitude: ${myLocation.longitude}"),
                      Text(
                          "Address: ${myPlacemark.first.country}, ${myPlacemark.first.administrativeArea}, ${myPlacemark.first.subAdministrativeArea}, ${myPlacemark.first.subLocality}")
                    ],
                  )
                : Text(""))
          ],
        ),
      ),
    );
  }
}

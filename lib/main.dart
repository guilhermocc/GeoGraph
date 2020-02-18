import 'package:epictour/MapPage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EpicTour App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => HomePage(title: "EpicTour HomeScreen"),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/map': (context) => MapPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Position myLocation;
  List<Placemark> myPlacemark;


  Future<void>_onGetMyLocation() async{
    Position currentLocation =  await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude,localeIdentifier: "en");
    setState(() {
      myLocation = currentLocation;
      myPlacemark = placemark;
    });
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
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              child: Text("Show my map"),
              color: Colors.lightGreen,
              onPressed: () { Navigator.pushNamed(context, '/map'); } ,
            ),
            MaterialButton(
              child: Text("Get my location"),
              color: Colors.lightGreen,
              onPressed: () { _onGetMyLocation();},
            ),
            (myLocation != null?
                Column(
                  children: <Widget>[
                          Text(
                          "Latitude: ${myLocation.latitude}, Longitude: ${myLocation.longitude}"),
                          Text(
                            "Address: ${myPlacemark.first.country}, ${myPlacemark.first.administrativeArea}, ${myPlacemark.first.subAdministrativeArea}, ${myPlacemark.first.subLocality}"
                          )
                           ],
                )
                : Text(""))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
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
                            child: Text(
                              'Giovanna Rodrigues',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ))
                      ],
                    ),
                    Divider(height: 20),
                  ],
                )),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Criar Grupo'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Meus Grupos'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Entrar em um Grupo'),
            ),
            ListTile(
              leading: Icon(Icons.outlined_flag),
              title: Text('LogOut'),
            ),
            Divider(
              height: 100,
            ),
            ListTile(
              title: Text("LogOut"),
              leading: Icon(Icons.arrow_back),
              onTap: _onLogout,
            ),
            ListTile(
              leading: Icon(Icons.android),
              title: Text('FAQ'),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Container(
                      height: (MediaQuery.of(context).size.height) / 2.5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Text("Sample Caixa"),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Container(
                      height: (MediaQuery.of(context).size.height) / 2.5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Text("Sample Caixa"),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Container(
                      height: (MediaQuery.of(context).size.height) / 2.5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Text("Sample Caixa"),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text("Sample Caixa"),
                      height: (MediaQuery.of(context).size.height) / 2.5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

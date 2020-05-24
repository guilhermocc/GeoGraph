import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geograph/blocs/splash.bloc.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashBloc bloc = SplashBloc();

  @override
  initState() {
    bloc.refreshStores(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "GeoGraph",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Theme.of(context).primaryColor),
                  )),
              Container(
                  padding: EdgeInsets.only(top: 90),
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

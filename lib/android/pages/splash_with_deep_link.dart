import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geograph/blocs/splash.bloc.dart';
import 'home.dart';

class SplashWithDeepLinkPage extends StatefulWidget {
  SplashWithDeepLinkPage({Key key,  this.queryParams}) : super(key: key);

  List<dynamic> queryParams;

  @override
  _SplashWithDeepLinkPageState createState() => _SplashWithDeepLinkPageState(queryParams: queryParams);
}

class _SplashWithDeepLinkPageState extends State<SplashWithDeepLinkPage> {
  _SplashWithDeepLinkPageState({this.queryParams});

  List<dynamic> queryParams;

  final SplashBloc bloc = SplashBloc();

  @override
  initState() {
    bloc.refreshStoresWithDeepLink(context, queryParams);
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
                        fontWeight: FontWeight.bold, fontSize: 40, color: Theme.of(context).primaryColor),
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

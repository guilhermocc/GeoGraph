import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/blocs/user.bloc.dart';

class SplashBloc {
  final UserBloc userBloc = UserBloc();

  void refreshStores(BuildContext context) async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    updateUserStore(currentUser, context);
  }

  void updateUserStore(FirebaseUser currentUser, BuildContext context) async {
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      DocumentSnapshot userSnapShot = await Firestore.instance
          .collection("users")
          .document(currentUser.uid)
          .get();

      userBloc.updateUserStore(userSnapShot, context);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }
}

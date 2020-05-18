import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geograph/android/home.dart';

class LoginFormBloc {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  var isLoading = false;
  var emailInputController = new TextEditingController();
  var passwordInputController = new TextEditingController();

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email está em um formato inválido';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  login(BuildContext context) async {
    // TODO It would be better to include here the error handling for these
    // methods call
    if (loginFormKey.currentState.validate()) {
      this.isLoading = true;
      AuthResult authResult = await signInWithLoginInfo();
      DocumentSnapshot userSnapshot = await getUserInfo(authResult);
      navigateToHomePage(userSnapshot, context);
    }
  }

   signInWithLoginInfo() async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: this.emailInputController.text,
            password: this.passwordInputController.text);

  }

  Future<DocumentSnapshot> getUserInfo(AuthResult authResult) {
    return Firestore.instance
        .collection("users")
        .document(authResult.user.uid)
        .get()
        .catchError((err) => this.isLoading = false);
    ;
  }

  Future<Object> navigateToHomePage(
      DocumentSnapshot userSnapShot, BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  title: "Bem vindo " + capitalize(userSnapShot["fname"]),
                  uid: userSnapShot["uid"],
                ))).catchError((err) => this.isLoading = false);
    ;
  }
}

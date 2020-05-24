import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/blocs/user.bloc.dart';
import 'package:geograph/store/user/user.dart';

class LoginBloc {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final UserBloc userBloc = UserBloc();
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

  login(BuildContext context) async {
    // TODO It would be better to include here the error handling for these
    // methods call
    if (loginFormKey.currentState.validate()) {
      this.isLoading = true;
      AuthResult authResult = await signInWithLoginInfo();
      DocumentSnapshot userSnapshot = await getUserInfo(authResult);
      loadUserInfo(userSnapshot, context);
      navigateToHomePage(userSnapshot, context);
    }
  }

  signInWithLoginInfo() async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
        email: this.emailInputController.text,
        password: this.passwordInputController.text);
  }

  Future<DocumentSnapshot> getUserInfo(AuthResult authResult) {
    return Firestore.instance
        .collection("users")
        .document(authResult.user.uid)
        .get()
        .catchError((err) => this.isLoading = false);
  }

  Future<Object> navigateToHomePage(
      DocumentSnapshot userSnapShot, BuildContext context) {
    return Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()))
        .catchError((err) => this.isLoading = false);
  }

  handleLoginError(err, BuildContext context) {
    this.isLoading = false;
    if (err.code == "ERROR_WRONG_PASSWORD" ||
        err.code == "ERROR_USER_NOT_FOUND") {
      this.showErrorDialog(context, "Email ou senha incorretos");
    } else {
      {
        this.showErrorDialog(context, "Houve um erro ao realizar o login");
      }
    }
  }

  showErrorDialog(BuildContext context, String textContent) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erro"),
            content: Text(textContent),
            actions: <Widget>[
              FlatButton(
                child: Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void loadUserInfo(DocumentSnapshot userSnapShot, BuildContext context) {
    userBloc.updateUserStore(userSnapShot, context);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/blocs/user.bloc.dart';

class RegisterBloc {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final UserBloc userBloc = UserBloc();
  TextEditingController firstNameInputController = new TextEditingController();
  TextEditingController lastNameInputController = new TextEditingController();
  TextEditingController emailInputController = new TextEditingController();
  TextEditingController passwordInputController = new TextEditingController();
  TextEditingController confirmPasswordInputController =
      new TextEditingController();
  bool isLoading = false;

  createAccount(BuildContext context) async {
    if (registerFormKey.currentState.validate()) {
      if (this.passwordInputController.text ==
          this.confirmPasswordInputController.text) {
        this.isLoading = true;
        AuthResult authResult = await createUserWithEmailAndPassword();
        await updateUserData(authResult);
        await loadUserInfo(context, authResult);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                    )),
            (_) => false);
        this.firstNameInputController.clear();
        this.lastNameInputController.clear();
        this.emailInputController.clear();
        this.passwordInputController.clear();
        this.confirmPasswordInputController.clear();
      } else {
        showErrorDialog(context, "As senhas não conferem.");
      }
    }
  }

  createTouristGuideAccount(BuildContext context) async {
    if (registerFormKey.currentState.validate()) {
      if (this.passwordInputController.text ==
          this.confirmPasswordInputController.text) {
        this.isLoading = true;
        AuthResult authResult = await createUserWithEmailAndPassword();
        await updateTouristGuideData(authResult);
        await loadUserInfo(context, authResult);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                )),
                (_) => false);
        this.firstNameInputController.clear();
        this.lastNameInputController.clear();
        this.emailInputController.clear();
        this.passwordInputController.clear();
        this.confirmPasswordInputController.clear();
      } else {
        showErrorDialog(context, "As senhas não conferem.");
      }
    }
  }


  createUserWithEmailAndPassword() async {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: this.emailInputController.text,
        password: this.passwordInputController.text);
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

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);


  updateUserData(AuthResult currentUser) async {
    return Firestore.instance
        .collection("users")
        .document(currentUser.user.uid)
        .setData({
      "uid": currentUser.user.uid,
      "fname": capitalize(this.firstNameInputController.text.trim()),
      "surname": capitalize(this.lastNameInputController.text.trim()),
      "email": this.emailInputController.text.trim(),
      "type": "user",
      "marker": {
        "position":
        GeoPoint(0.0, 0.0),
        "userName": this.firstNameInputController.text.trim() +
            " " +
            this.lastNameInputController.text.trim(),
      }
    });
  }

  updateTouristGuideData(AuthResult currentUser) async {
    return Firestore.instance
        .collection("users")
        .document(currentUser.user.uid)
        .setData({
      "uid": currentUser.user.uid,
      "fname": capitalize(this.firstNameInputController.text.trim()),
      "surname": capitalize(this.lastNameInputController.text.trim()),
      "email": this.emailInputController.text.trim(),
      "type": "tourist_guide",
      "marker": {
        "position":
        GeoPoint(0.0, 0.0),
        "userName": this.firstNameInputController.text.trim() +
            " " +
            this.lastNameInputController.text.trim(),
      }
    });
  }


  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'O Email está em um formato inválido';
    } else {
      return null;
    }
  }

  handleRegistrationError(PlatformException err, BuildContext context) {
    this.isLoading = false;
    if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
      this.showErrorDialog(context, "E-mail já está em uso");
    } else {
      {
        this.showErrorDialog(context, "Houve um erro ao criar a conta");
      }
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A Senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
  }

  String nameValidator(String value) {
    if (value.length < 1) {
      return "O nome deve ter ao menos 1 caractere.";
    } else {
      return null;
    }
  }

  void loadUserInfo(BuildContext context, AuthResult currentuser) async {
    DocumentSnapshot userSnapShot = await Firestore.instance
        .collection("users")
        .document(currentuser.user.uid)
        .get();

    userBloc.updateUserStore(userSnapShot, context);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/android/pages/map.dart';
import 'package:geograph/blocs/user.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroupBloc {
  final GlobalKey<FormState> createGroupFormKey = GlobalKey<FormState>();
  final UserBloc userBloc = UserBloc();
  TextEditingController nameInputController = new TextEditingController();
  TextEditingController descriptionInputController =
      new TextEditingController();
  TextEditingController passwordInputController =
      new TextEditingController();
  TextEditingController confirmPasswordInputController =
      new TextEditingController();
  bool isLoading = false;

  createGroup(BuildContext context) async {
    if (createGroupFormKey.currentState.validate()) {
      if (this.passwordInputController.text ==
          this.confirmPasswordInputController.text) {
        this.isLoading = true;
        User user = Provider.of<User>(context, listen: false);
        var uuid = new Uuid();


        DocumentReference groupCreated = await Firestore.instance.collection("groups").add(
          {
            "identifier": uuid.v1(),
            "password": passwordInputController.text,
            "title": nameInputController.text,
            "description": descriptionInputController.text,
            "members": [
              {
                "type": "admin",
                "uid": user.documentReference
              }
            ]
          }
        );

        DocumentSnapshot groupSnapShot = await groupCreated.get();

        navigateToGroupPage(groupSnapShot, context, user);
        this.nameInputController.clear();
        this.descriptionInputController.clear();
        this.passwordInputController.clear();
        this.confirmPasswordInputController.clear();
      } else {
        showErrorDialog(context, "As senhas não conferem.");
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

  updateUserData(AuthResult currentUser) async {
    return Firestore.instance
        .collection("users")
        .document(currentUser.user.uid)
        .setData({
      "uid": currentUser.user.uid,
      "fname": this.nameInputController.text,
      "surname": this.descriptionInputController.text,
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

  handleGroupCreationError(PlatformException err, BuildContext context) {
    this.isLoading = false;
    if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
      this.showErrorDialog(context, "E-mail já está em uso");
    } else {
      {
        this.showErrorDialog(context, "Houve um erro ao criar a conta");
      }
    }
  }

  navigateToGroupPage(DocumentSnapshot groupSnapShot, BuildContext context, User user) async {
    var groupData = groupSnapShot.data;
    List membersArray =
    groupData["members"].map((member) => member["uid"].documentID).toList();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(
                userId: user.uid,
                groupId: groupSnapShot.documentID,
                membersArray: membersArray)));
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A Senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
  }

  String nameValidator(String value) {
    if (value.length < 3) {
      return "O nome do grupo deve possuir ao menos 3 caracteres";
    } else {
      return null;
    }
  }

}

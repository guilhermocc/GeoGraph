import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/android/pages/map.dart';
import 'package:geograph/blocs/user.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

class EnterNewGroupBloc {
  final GlobalKey<FormState> enterGroupFormKey = GlobalKey<FormState>();
  final UserBloc userBloc = UserBloc();
  var isLoading = false;
  var identifierInputController = new TextEditingController();
  var passwordInputController = new TextEditingController();

  String identifierValidator(String value) {
//    Pattern pattern =
//        r'........-....-....-....-............';
//    RegExp regex = new RegExp(pattern);
//    if (!regex.hasMatch(value)) {
    if (false) {
      return 'O identificador está em um formato inválido';
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

  enterGroup(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);

    // TODO It would be better to include here the error handling for these
    if (enterGroupFormKey.currentState.validate()) {
      this.isLoading = true;
      QuerySnapshot groupQuery = await Firestore.instance
          .collection("groups")
          .where("identifier",
              isEqualTo: identifierInputController.text)
          .limit(1)
          .getDocuments();
      DocumentSnapshot group = groupQuery.documents.first;
      if (group.data["password"] == passwordInputController.text) {
        await addUserToGroup(group, user);
        await navigateToGroupPage(group, context, user);
      } else {
        throw ("Wrong password");

      }
    }
  }

  signInWithLoginInfo() async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
        email: this.identifierInputController.text,
        password: this.passwordInputController.text);
  }

  Future<DocumentSnapshot> getUserInfo(AuthResult authResult) {
    return Firestore.instance
        .collection("users")
        .document(authResult.user.uid)
        .get()
        .catchError((err) => this.isLoading = false);
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

  handleEnterGroupError(err, BuildContext context) {
    this.isLoading = false;
    this.showErrorDialog(context, "Erro ao entrar no grupo");
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

  void addUserToGroup(DocumentSnapshot snapshot, User user) async {
    // TODO i should use FieldValue arrayUnion here
    List<dynamic> membersList = snapshot.data["members"];
    membersList
        .add({"type": "neutral", "uid": user.documentReference});
    await Firestore.instance
        .collection("groups")
        .document(snapshot.reference.documentID)
        .updateData({"members": membersList});
  }
}

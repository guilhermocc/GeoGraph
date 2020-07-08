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
    Pattern pattern =
        r'\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
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

      if (group.data["members"].any((member) => member["uid"].documentID == user.uid)) {
        throw ("Already in group");
      }

      if (group.data["password"] == passwordInputController.text) {
        var newMembersList =  await addUserToGroup(group, user);
        await navigateToGroupPage(newMembersList, context, user, group);
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

  navigateToGroupPage(List newMembersList, BuildContext context,
      User user, DocumentSnapshot groupSnapShot) async {
    List<String> membersUidList = new List<String>.from(
        newMembersList.map((member) => member["uid"].documentID).toList()
    );
    List<dynamic> membersList = newMembersList;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MapPage(
                    userId: user.uid,
                    groupId: groupSnapShot.documentID,
                    groupTitle: groupSnapShot["title"],
                    groupDescription: groupSnapShot["description"],
                    membersUidList: membersUidList,
                    membersList: membersList
                )));
  }

  handleEnterGroupError(err, BuildContext context) {
    this.isLoading = false;
    if (err == "Already in group")
      this.showErrorDialog(context, "Você já está neste grupo!");
    else
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

  Future<List> addUserToGroup(DocumentSnapshot snapshot, User user) async {
    // TODO i should use FieldValue arrayUnion here
    List<dynamic> membersList = snapshot.data["members"];
    membersList
        .add({"type": "neutral", "uid": user.documentReference});
    await Firestore.instance
        .collection("groups")
        .document(snapshot.reference.documentID)
        .updateData({"members": membersList});
    return membersList;
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/blocs/user.bloc.dart';
import 'package:geograph/main.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

class MyGroupsBloc {
//  User userStore;

//  MyGroupsBloc(BuildContext context) {
//    this.userStore = Provider.of<User>(context, listen: false);
//  }
//
//  queryGroups() async {
//    log('Fetching user groups');
//    log(this.userStore.uid);
//    CollectionReference groupReference = Firestore.instance.collection(
//        "groups");
//    DocumentReference userReference = Firestore.instance.collection("users")
//        .document(userStore.uid);
//    var test = await groupReference.getDocuments();
//    QuerySnapshot documents = await groupReference.where(
//        'members', arrayContains: userReference).getDocuments();
//    var number = documents.documents;
//    log('finished');
//  }
//
//
//  addMember() async {
//    log('Adding user to group');
//    log(this.userStore.uid);
//    CollectionReference groupReference = Firestore.instance.collection(
//        "groups");
//    DocumentReference userReference = Firestore.instance.collection("users")
//        .document(userStore.uid);
//    DocumentReference groupDocumentReference = Firestore.instance.collection(
//        "groups").document("dYSMIE77NxgoxSPorOmW");
//    DocumentSnapshot snapshot = await groupDocumentReference.get();
//    List<dynamic> members = snapshot.data["members"];
//    members.add(userReference);
//    groupDocumentReference.setData({
//      "members": members
//    });
//
//    log('finished');
//  }
//
//
//  removeMember() async {
//    log('Removing user to group');
//    log(this.userStore.uid);
//    CollectionReference groupReference = Firestore.instance.collection(
//        "groups");
//    DocumentReference userReference = Firestore.instance.collection("users")
//        .document(userStore.uid);
//    DocumentReference groupDocumentReference = Firestore.instance.collection(
//        "groups").document("dYSMIE77NxgoxSPorOmW");
//    DocumentSnapshot snapshot = await groupDocumentReference.get();
//    List<dynamic> members = snapshot.data["members"];
//    DocumentReference member = members[0];
//    members.removeWhere((member) => member.documentID == userStore.uid);
//    groupDocumentReference.setData({
//      "members": members
//    });
//
//    log('finished');
//  }

  Future<List<DocumentSnapshot>> getGroups(context) {
    User userStore = Provider.of<User>(context, listen: false);

    DocumentReference userReference =
        Firestore.instance.collection("users").document(userStore.uid);

    return Firestore.instance
        .collection("groups")
        .where('members', arrayContainsAny: [
          {'uid': userReference, 'type': 'admin'},
          {'uid': userReference, 'type': 'neutral'}
        ])
        .getDocuments()
        .then((QuerySnapshot queryResult) => queryResult.documents);
  }
}

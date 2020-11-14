import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geograph/android/pages/enter_new_group.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/android/pages/login.dart';
import 'package:geograph/android/pages/map.dart';
import 'package:geograph/blocs/user.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({WidgetBuilder builder}) : super(builder: builder);

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

class SplashBloc {
  final UserBloc userBloc = UserBloc();

  Future<T> pushWithoutAnimation<T extends Object>(Widget page, BuildContext context) {
    Route route = NoAnimationPageRoute(builder: (BuildContext context) => page);
    return Navigator.pushReplacement(context, route);
  }

  void refreshStoresWithDeepLink(BuildContext context, List<dynamic> queryParams) async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    await updateUserStoreWithDeepLink(currentUser, context, queryParams);
  }

  void updateUserStoreWithDeepLink(FirebaseUser currentUser, BuildContext context, List<dynamic> queryParams) async {
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      DocumentSnapshot userSnapShot = await Firestore.instance.collection("users").document(currentUser.uid).get();

      userBloc.updateUserStore(userSnapShot, context);
      User user = Provider.of<User>(context, listen: false);

      pushWithoutAnimation(HomePage(title: "Home"), context);

      if (queryParams.where((queryParam) => queryParam.key == "groupId").isNotEmpty) {
        var groupId = queryParams.where((queryParam) => queryParam.key == "groupId").first.value.first;
        DocumentSnapshot group = await Firestore.instance
            .collection("groups")
            .document(groupId)
            .get();

        if (group.data["members"].any((member) => member["uid"].documentID == user.uid)) {
          throw ("Already in group");
        }

        var newMembersList = await addUserToGroup(group, user);
        await navigateToGroupPage(newMembersList, context, user, group);
      }
    }
  }

  navigateToGroupPage(List newMembersList, BuildContext context, User user,
      DocumentSnapshot groupSnapShot) async {
    List<String> membersUidList = new List<String>.from(
        newMembersList.map((member) => member["uid"].documentID).toList());
    List<dynamic> membersList = newMembersList;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(
                userId: user.uid,
                groupId: groupSnapShot.documentID,
                groupTitle: groupSnapShot["title"],
                groupDescription: groupSnapShot["description"],
                membersUidList: membersUidList,
                membersList: membersList)));
  }

  Future<List> addUserToGroup(DocumentSnapshot snapshot, User user) async {
    // TODO i should use FieldValue arrayUnion here
    List<dynamic> membersList = snapshot.data["members"];
    user.type == "tourist_guide"
        ? membersList.add({"type": "admin", "uid": user.documentReference})
        : membersList.add({"type": "neutral", "uid": user.documentReference});
    await Firestore.instance
        .collection("groups")
        .document(snapshot.reference.documentID)
        .updateData({"members": membersList});
    return membersList;
  }

  void refreshStores(BuildContext context) async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    updateUserStore(currentUser, context);
  }

  void updateUserStore(FirebaseUser currentUser, BuildContext context) async {
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      DocumentSnapshot userSnapShot = await Firestore.instance.collection("users").document(currentUser.uid).get();

      userBloc.updateUserStore(userSnapShot, context);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }
}

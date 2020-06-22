import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geograph/main.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

class UserBloc {
  void updateUserStore(DocumentSnapshot userSnapShot, BuildContext context) {
    User userStore = Provider.of<User>(context, listen: false);
    userStore.setFirstName(userSnapShot["fname"]);
    userStore.setLastName(userSnapShot["surname"]);
    userStore.setEmail(userSnapShot["email"]);
    userStore.setUid(userSnapShot["uid"]);
    userStore.setDocumentReference(userSnapShot.reference);
  }

  void resetUserStore(BuildContext context) {
    User userStore = Provider.of<User>(context, listen: false);
    userStore.setFirstName("");
    userStore.setLastName("");
    userStore.setEmail("");
    userStore.setUid("");
    userStore.setDocumentReference(null);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:geograph/blocs/user.bloc.dart';

class HomeBloc {
  UserBloc userBloc = UserBloc();

  onLogout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    userBloc.resetUserStore(context);
    Navigator.pushReplacementNamed(context, "/splash");
  }
}

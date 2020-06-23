import 'package:geograph/android/pages/create_group.dart';
import 'package:geograph/android/pages/map.dart';
import 'package:geograph/android/pages/register.dart';
import 'package:geograph/android/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

import 'android/pages/enter_new_group.dart';
import 'android/pages/home.dart';
import 'android/pages/login.dart';
import 'android/pages/my_groups.dart';

void main() => runApp(App());
final User user = User();

class App extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [Provider(create: (_) => User())],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                primaryColor: Color(0xFF6200EE),
                primaryColorLight: Color(0xFF9e47ff),
                primaryColorDark: Color(0xFF0400ba)),
            home: SplashPage(),
            routes: <String, WidgetBuilder>{
              '/home': (BuildContext context) => HomePage(title: 'Home'),
              '/login': (BuildContext context) => LoginPage(),
              '/register': (BuildContext context) => RegisterPage(),
              '/map': (BuildContext context) => MapPage(),
              '/splash': (BuildContext context) => SplashPage(),
              '/my_groups': (BuildContext context) => MyGroupsPage(),
              '/create_group': (BuildContext context) => CreateGroupPage(),
              '/enter_new_group': (BuildContext context) => EnterNewGroupPage(),
            }));
  }
}

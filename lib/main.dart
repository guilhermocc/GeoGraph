import 'dart:async';

import 'package:geograph/android/pages/create_group.dart';
import 'package:geograph/android/pages/group_update_page.dart';
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
import 'android/pages/register_tourist_guide.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

void main() => runApp(App());
final User user = User();

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {

  // Application widget root.
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
              '/register_tourist_guide': (BuildContext context) => RegisterTouristGuidePage(),
              '/map': (BuildContext context) => MapPage(),
              '/splash': (BuildContext context) => SplashPage(),
              '/my_groups': (BuildContext context) => MyGroupsPage(),
              '/create_group': (BuildContext context) => CreateGroupPage(),
              '/enter_new_group': (BuildContext context) => EnterNewGroupPage(),
              '/group_info': (BuildContext context) => GroupUpdatePage()
            }));
  }
}

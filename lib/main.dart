import 'package:geograph/android/map.dart';
import 'package:geograph/android/register.dart';
import 'package:geograph/android/splash.dart';
import 'package:flutter/material.dart';

import 'android/home.dart';
import 'android/login.dart';

void main() => runApp(App());

class App extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.cyan),
        home: SplashPage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomePage(title: 'Home'),
          '/login': (BuildContext context) => LoginPage(),
          '/register': (BuildContext context) => RegisterPage(),
          '/map': (BuildContext context) => MapPage(),
          '/splash': (BuildContext context) => SplashPage()
        });
  }
}

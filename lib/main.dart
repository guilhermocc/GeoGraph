import 'dart:async';

import 'package:geograph/android/pages/create_group.dart';
import 'package:geograph/android/pages/group_update_page.dart';
import 'package:geograph/android/pages/map.dart';
import 'package:geograph/android/pages/register.dart';
import 'package:geograph/android/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:geograph/android/pages/splash_with_deep_link.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

import 'android/pages/enter_new_group.dart';
import 'android/pages/home.dart';
import 'android/pages/login.dart';
import 'android/pages/my_groups.dart';
import 'android/pages/register_tourist_guide.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

void main() => runApp(App());
final User user = User();

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  String _latestLink = 'Unknown';
  Uri _latestUri;

  StreamSubscription _sub;

  TabController _tabController;

  final TextStyle _cmdStyle = const TextStyle(fontFamily: 'Courier', fontSize: 12.0, fontWeight: FontWeight.w700);
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    initUniLinks();
    initPlatformState();
  }

  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      getInitialUri().then((value) {
        if (!mounted) return;
        setState(() {
          _latestUri = value;
          _latestLink = value?.toString() ?? 'Unknown';
        });
      });

      // Use the uri and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on FormatException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    await initPlatformStateForUriUniLinks();
  }

  /// An implementation using the [Uri] convenience helpers
  initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _latestLink = uri?.toString() ?? 'Unknown';
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        _latestLink = 'Failed to get latest link: $err.';
      });
    });

    // Attach a second listener to the stream
    getUriLinksStream().listen((Uri uri) {
      print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest Uri
    Uri initialUri;
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      print('initial uri: ${initialUri?.path}'
          ' ${initialUri?.queryParametersAll}');
      initialLink = initialUri?.toString();
    } on PlatformException {
      initialUri = null;
      initialLink = 'Failed to get initial uri.';
    } on FormatException {
      initialUri = null;
      initialLink = 'Bad parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestUri = initialUri;
      _latestLink = initialLink;
    });
  }

  // Application widget root.
  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll?.entries?.toList();
    if (queryParams != null) {
      return MultiProvider(
          providers: [Provider(create: (_) => User())],
          child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                  primaryColor: Color(0xFF6200EE),
                  primaryColorLight: Color(0xFF9e47ff),
                  primaryColorDark: Color(0xFF0400ba)),
              home: SplashWithDeepLinkPage(queryParams: queryParams,),
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
    } else {
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
}

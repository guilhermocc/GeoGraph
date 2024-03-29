import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:geograph/blocs/home.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position myLocation;
  List<Placemark> myPlacemark;
  HomeBloc bloc = HomeBloc();

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Menu Inicial')),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/person_1.jpg'),
                            backgroundColor: Colors.transparent,
                          ),
                          Container(
                              padding: EdgeInsets.only(bottom: 10, left: 10),
                              child: Observer(
                                builder: (_) => Text(
                                  "${user.firstName}  ${user.lastName}".trim(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ],
                  )),
              user.type == "tourist_guide"
                  ? ListTile(
                      leading: Icon(
                        Icons.library_add,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, '/create_group'),
                      title: Text('Criar Grupo'),
                    )
                  : Container(),
              ListTile(
                leading: Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColorDark,
                ),
                onTap: () => Navigator.pushNamed(context, '/my_groups'),
                title: Text('Meus Grupos'),
              ),
              ListTile(
                leading: Icon(
                  Icons.group_add,
                  color: Theme.of(context).primaryColorDark,
                ),
                onTap: () => Navigator.pushNamed(context, '/enter_new_group'),
                title: Text('Entrar em um Grupo'),
              ),
              Divider(
                height: 50,
                thickness: 2,
              ),
              ListTile(
                title: Text("LogOut"),
                leading: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).primaryColorDark,
                ),
                onTap: () => bloc.onLogout(context),
              ),
            ],
          ),
        ),
        body: Image(
          image: AssetImage('assets/menu.jpg'),
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ));
  }
}

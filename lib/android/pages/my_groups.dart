import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/blocs/my_groups.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

import 'map.dart';

class MyGroupsPage extends StatefulWidget {
  MyGroupsPage({Key key}) : super(key: key);

  @override
  MyGroupPageState createState() => MyGroupPageState();
}

class MyGroupPageState extends State<MyGroupsPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyGroupsBloc bloc = MyGroupsBloc();
    User user = Provider.of<User>(context);

    return FutureBuilder<List<DocumentSnapshot>>(
      future: bloc.getGroups(context),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshots) {
        if (snapshots.hasData) {
          List<DocumentSnapshot> groups = snapshots.data;

          if (groups.isNotEmpty) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Meus Grupos"),
                ),
                body: ListView(
                  children: groups
                      .map((group) => Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.people,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              title: Text(group.data["title"]),
                              subtitle: Text(descriptionAbstract(group.data["description"])),
                              trailing: Icon(
                                Icons.keyboard_arrow_right,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onTap: () async {
                                var groupSnapShot = await Firestore.instance
                                    .collection("groups")
                                    .document(group.documentID)
                                    .get();
                                var groupData = groupSnapShot.data;
                                List membersArray = groupData["members"]
                                    .map((member) => member["uid"].documentID)
                                    .toList();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MapPage(
                                            userId: user.uid,
                                            groupId: group.documentID,
                                            membersArray: membersArray)));
                              },
                            ),
                          ))
                      .toList(),
                ));
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Meus grupos"),
                ),
                body: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Icon(
                            Icons.layers_clear,
                            color: Theme.of(context).primaryColorDark,
                            size: 100,
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text(
                              "Você não está presente em nenhum grupo!",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        )
                      ],
                    )));
          }
        } else {
          return Scaffold(
              appBar: AppBar(
                title: Text("Meus grupos"),
              ),
              body: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )));
        }
      },
    );
  }

  fetchData(User userStore) async {}

  String descriptionAbstract(String data) {
    String singleLine = data.replaceAll("\n", " ").trim();
    if(singleLine.length < 40) {
      return singleLine;
    }
    return singleLine.substring(0, 37).trim() + "...";
  }
}

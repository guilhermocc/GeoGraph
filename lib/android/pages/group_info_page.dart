import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/blocs/create_group.bloc.dart';
import 'package:geograph/blocs/update_group.bloc.dart';
import 'package:geograph/store/user/user.dart';

class GroupInfoPage extends StatefulWidget {
  GroupInfoPage({Key key, this.groupId, this.userType}) : super(key: key);
  final String groupId;
  final String userType;

  @override
  GroupInfoPageState createState() => GroupInfoPageState();
}

class GroupInfoPageState extends State<GroupInfoPage> {
  UpdateGroupBloc bloc = new UpdateGroupBloc();
  TextEditingController _controller;
  bool _isChangingPassword = false;
  bool _updateSuccessful = true;
  bool _triedToUpdate = false;

  @override
  initState() {
    super.initState();
  }

  Future<DocumentSnapshot> loadGroupInfo() async {
    _controller = TextEditingController();
    return Firestore.instance
        .collection("groups")
        .document(widget.groupId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: loadGroupInfo(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot groupSnapshot = snapshot.data;
            var groupData = groupSnapshot.data;
            String groupTitle = groupData["title"];
            String groupDescription = groupData["description"];
            String groupIdentifier = groupData["identifier"];
            String groupPassword = groupData["password"];
            int groupUsersNumber = groupData["members"].length;

            bloc.identifierController.text = groupIdentifier;
            bloc.groupTitleController.text = groupTitle;
            bloc.groupDescriptionController.text = groupDescription;

            return Scaffold(
                appBar: AppBar(
                  title: Text("Informações do grupo"),
                ),
                body: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: bloc.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              backgroundColor:
                                  Theme.of(context).primaryColorLight,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Form(
                            key: bloc.updateGroupFormKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF9FAFC),
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                  ),
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(
                                            'https://i.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI'),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      TextFormField(
                                        controller: bloc.identifierController,
                                        decoration: InputDecoration(
                                            labelText: "Identificador do Grupo",
                                            labelStyle:
                                                TextStyle(fontSize: 20)),
                                        readOnly: true,
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            labelText: "Nome do grupo",
                                            labelStyle:
                                                TextStyle(fontSize: 20)),
                                        enableInteractiveSelection: false,
                                        controller: bloc.groupTitleController,
                                        validator: bloc.nameValidator,
                                        readOnly: true,
                                      ),
                                      TextFormField(
                                          decoration: InputDecoration(
                                              labelText: "Descrição",
                                              labelStyle:
                                                  TextStyle(fontSize: 20)),
                                          controller:
                                              bloc.groupDescriptionController,
                                          validator: bloc.descriptionValidator,
                                          readOnly: true,
                                          maxLines: 2,
                                          keyboardType:
                                              TextInputType.multiline),
                                      TextFormField(
                                          decoration: InputDecoration(
                                              labelText:
                                                  "Quantidade de membros",
                                              labelStyle:
                                                  TextStyle(fontSize: 20)),
                                          initialValue:
                                              groupUsersNumber.toString(),
                                          readOnly: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))));
          }
          return Container();
        });

    fetchData(User userStore) async {}
  }
}

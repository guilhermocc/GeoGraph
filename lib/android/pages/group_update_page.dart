import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/blocs/create_group.bloc.dart';
import 'package:geograph/blocs/update_group.bloc.dart';
import 'package:geograph/store/user/user.dart';

class GroupUpdatePage extends StatefulWidget {
  GroupUpdatePage({Key key, this.groupId, this.userType}) : super(key: key);
  final String groupId;
  final String userType;

  @override
  GroupUpdatePageState createState() => GroupUpdatePageState();
}

class GroupUpdatePageState extends State<GroupUpdatePage> {
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
                                        decoration: InputDecoration(
                                            labelText: "Nome do grupo",
                                            labelStyle:
                                                TextStyle(fontSize: 20)),
                                        enableInteractiveSelection: false,
                                        controller: bloc.groupTitleController,
                                        validator: bloc.nameValidator,
                                        readOnly: widget.userType == "admin"
                                            ? false
                                            : true,
                                      ),
                                      TextFormField(
                                          decoration: InputDecoration(
                                              labelText: "Descrição",
                                              labelStyle:
                                                  TextStyle(fontSize: 20)),
                                          controller:
                                              bloc.groupDescriptionController,
                                          validator: bloc.descriptionValidator,
                                          readOnly: widget.userType == "admin"
                                              ? false
                                              : true,
                                          maxLines: 2,
                                          keyboardType:
                                              TextInputType.multiline),
                                      _isChangingPassword
                                          ? Column(
                                              children: <Widget>[
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    labelText: "Senha atual",
                                                    labelStyle:
                                                        TextStyle(fontSize: 16),
                                                    // Here is key idea
                                                  ),
                                                  validator: bloc.pwdValidator,
                                                  controller: bloc
                                                      .currentPasswordConfirmationController,
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    labelText: "Nova senha",
                                                    labelStyle:
                                                        TextStyle(fontSize: 16),
                                                    // Here is key idea
                                                  ),
                                                  validator: bloc.pwdValidator,
                                                  controller: bloc
                                                      .newPasswordController,
                                                ),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Confirmação da nova senha",
                                                    labelStyle:
                                                        TextStyle(fontSize: 16),
                                                    // Here is key idea
                                                  ),
                                                  validator: bloc.pwdValidator,
                                                  controller: bloc
                                                      .newPasswordConfirmationController,
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                widget.userType == "admin"
                                    ? RaisedButton(
                                        child: Text(_isChangingPassword
                                            ? "Cancelar nova senha"
                                            : "Criar nova senha"),
                                        color: Theme.of(context).primaryColor,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            _isChangingPassword =
                                                !_isChangingPassword;
                                          });
                                        },
                                      )
                                    : Container(),
                                widget.userType == "admin"
                                    ? RaisedButton(
                                        child: Text("Confirmar Alterações"),
                                        color: Theme.of(context).primaryColor,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          bool formValid = bloc.validateForm(
                                              context,
                                              _isChangingPassword,
                                              groupPassword);
                                          if (formValid) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) => Dialog(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  height: 300.0,
                                                                  width: 300.0,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.all(15.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              "Deseja confirmar as alterações?",
                                                                              style: TextStyle(color: Colors.black),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            top:
                                                                                50),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: <
                                                                              Widget>[
                                                                            RaisedButton(
                                                                              color: Theme.of(context).primaryColorDark,
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Text(
                                                                                'Não',
                                                                                style: TextStyle(fontSize: 18.0, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                            RaisedButton(
                                                                              color: Theme.of(context).primaryColorDark,
                                                                              onPressed: () {
                                                                                bool updateStatus = true;
                                                                                bloc.updateGroupInfo(widget.groupId, _isChangingPassword).catchError((error) => updateStatus = false);
                                                                                setState(() {
                                                                                  _triedToUpdate = true;
                                                                                  _updateSuccessful = updateStatus;
                                                                                });
                                                                                Navigator.of(context).pop();
                                                                                showDialog(context: context, builder:  (BuildContext context) => Dialog(
                                                                                  shape:
                                                                                  RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                        12.0),
                                                                                  ),
                                                                                  child:
                                                                                  Container(
                                                                                    height: 300.0,
                                                                                    width: 300.0,
                                                                                    child: Column(
                                                                                      mainAxisAlignment:
                                                                                      MainAxisAlignment
                                                                                          .center,
                                                                                      children: <
                                                                                          Widget>[
                                                                                        Padding(
                                                                                          padding:
                                                                                          EdgeInsets.all(15.0),
                                                                                          child:
                                                                                          Column(
                                                                                            crossAxisAlignment:
                                                                                            CrossAxisAlignment.start,
                                                                                            children: <
                                                                                                Widget>[
                                                                                              Text(
                                                                                                _updateSuccessful ? "Dados alterados com sucesso." : "Falha ao atualizar as informações, tente novamente.",
                                                                                                style: TextStyle(color: Colors.black),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(
                                                                                              left:
                                                                                              10,
                                                                                              right:
                                                                                              10,
                                                                                              top:
                                                                                              50),
                                                                                          child:
                                                                                          Row(
                                                                                            mainAxisAlignment:
                                                                                            MainAxisAlignment.spaceAround,
                                                                                            crossAxisAlignment:
                                                                                            CrossAxisAlignment.end,
                                                                                            children: <
                                                                                                Widget>[
                                                                                              RaisedButton(
                                                                                                color: Theme.of(context).primaryColorDark,
                                                                                                onPressed: () {
                                                                                                  if (_updateSuccessful) {
                                                                                                    int count = 0;
                                                                                                    Navigator.of(context).popUntil((_) => count++ >= 2);
                                                                                                  } else {
                                                                                                    Navigator.pop(context);
                                                                                                  }
                                                                                                },
                                                                                                child: Text(
                                                                                                  'Fechar',
                                                                                                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ));
                                                                              },
                                                                              child: Text(
                                                                                'Sim',
                                                                                style: TextStyle(fontSize: 18.0, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ));
                                          }
                                        },
                                      )
                                    : Container(),
                              ],
                            ),
                          ))));
          }
          return Container();
        });

    fetchData(User userStore) async {}
  }
}

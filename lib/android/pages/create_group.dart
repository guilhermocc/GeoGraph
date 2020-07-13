import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/blocs/create_group.bloc.dart';
import 'package:geograph/blocs/my_groups.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';

import 'map.dart';

class CreateGroupPage extends StatefulWidget {
  CreateGroupPage({Key key}) : super(key: key);

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {
  CreateGroupBloc bloc = new CreateGroupBloc();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Criar novo grupo"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: bloc.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: bloc.createGroupFormKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                            color: Color(0xFFF9FAFC),
                            borderRadius: new BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage('assets/groups.jpg'),
                                backgroundColor: Colors.transparent,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Nome do grupo*'),
                                controller: bloc.nameInputController,
                                validator: bloc.nameValidator,
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Senha do grupo*'),
                                controller: bloc.passwordInputController,
                                obscureText: true,
                                validator: bloc.pwdValidator,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Confirmação de senha*',
                                    hintText: "********"),
                                controller:
                                    bloc.confirmPasswordInputController,
                                obscureText: true,
                                validator: bloc.pwdValidator,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Descrição do grupo*'),
                                controller: bloc.descriptionInputController,
                                validator: bloc.descriptionValidator,
                                maxLines: 2,
                                  keyboardType: TextInputType.multiline

                              ),

                            ],
                          ),
                        ),
                        RaisedButton(
                          child: Text("Criar Grupo"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              bloc.createGroup(context).catchError((err) {
                                setState(() {
                                  bloc.handleGroupCreationError(err, context);
                                });
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ))));
  }

  fetchData(User userStore) async {}
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/blocs/login_form.bloc.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var bloc = new LoginFormBloc();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("GeoGraph"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: bloc.isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Expanded(
                child: Form(
                  key: bloc.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: "exemplo@email.com"),
                        controller: bloc.emailInputController,
                        keyboardType: TextInputType.emailAddress,
                        validator: bloc.emailValidator,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Senha', hintText: "********"),
                        controller: bloc.passwordInputController,
                        obscureText: true,
                        validator: bloc.pwdValidator,
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 20, bottom: 15),
                          child: RaisedButton(
                              child: Text("Entrar"),
                              color: Theme
                                  .of(context)
                                  .primaryColorDark,
                              textColor: Colors.white,
                              onPressed: () {
                                setState(() {
                                  // TODO It would be better to extract this logic
                                  // and error handling to bloc class
                                  bloc
                                      .login(context)
                                      .catchError((err) =>
                                      setState(() {
                                        bloc.isLoading = false;
                                      }));
                                });
                              })),
                      Row(children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Divider(
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                         child: Text(
                             'Ou'
                         ),
                        ),
                        Expanded(
                            child: Divider(
                              color: Colors.black,
                            )),
                      ]),
                      Container(
                        padding: EdgeInsets.only(top: 15),
                        child: RaisedButton(
                          child: Text("Crie sua conta"),
                          color: Theme
                              .of(context)
                              .primaryColorDark,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
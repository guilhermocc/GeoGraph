import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geograph/android/home.dart';
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
          title: Text("Tela de Login"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: bloc.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: bloc.loginFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Email*',
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
                        RaisedButton(
                          child: Text("Login"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              // TODO It would be better to extract this logic
                              // and error handling to bloc class
                              bloc
                                  .login(context)
                                  .catchError((err) => setState(() {
                                bloc.isLoading = false;
                              }));
                            });

                            }
                        ),
                        Text("Ainda não possuí conta?"),
                        FlatButton(
                          child: Text("Crie sua conta aqui!"),
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                        )
                      ],
                    ),
                  ))));
  }
}

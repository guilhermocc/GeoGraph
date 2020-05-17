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
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  bool isLoading = false;
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
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: _loginFormKey,
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
                            if (_loginFormKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: bloc.emailInputController.text,
                                      password: bloc.passwordInputController.text)
                                  .then((authResult) => Firestore.instance
                                          .collection("users")
                                          .document(authResult.user.uid)
                                          .get()
                                          .then((DocumentSnapshot result) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                      title: "Bem vindo " +
                                                          capitalize(
                                                              result["fname"]),
                                                      uid: authResult.user.uid,
                                                    )));
                                      }).catchError((err) => setState(() {
                                                isLoading = false;
                                              })))
                                  .catchError((err) => setState(() {
                                        isLoading = false;
                                      }));
                            }
                          },
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

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

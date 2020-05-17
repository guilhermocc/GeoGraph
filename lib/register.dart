import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geograph/home.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'O Email está em um formato inválido';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A Senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tela de Registro"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
              key: _registerFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Primeiro nome*'),
                    controller: firstNameInputController,
                    validator: (value) {
                      if (value.length < 3) {
                        return "Por favor insira um primeiro nome válido.";
                      }
                    },
                  ),
                  TextFormField(
                      decoration: InputDecoration(labelText: 'Segundo nome*'),
                      controller: lastNameInputController,
                      validator: (value) {
                        if (value.length < 3) {
                          return "Por favor insira um segundo nome válido.";
                        }
                      }),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email*'),
                    controller: emailInputController,
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Senha*'),
                    controller: pwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Confirmação de senha*',
                        hintText: "********"),
                    controller: confirmPwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                  ),
                  RaisedButton(
                    child: Text("Criar Conta"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_registerFormKey.currentState.validate()) {
                        if (pwdInputController.text ==
                            confirmPwdInputController.text) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: emailInputController.text,
                                  password: pwdInputController.text)
                              .then((currentUser) => Firestore.instance
                                  .collection("users")
                                  .document(currentUser.user.uid)
                                  .setData({
                                    "uid": currentUser.user.uid,
                                    "fname": firstNameInputController.text,
                                    "surname": lastNameInputController.text,
                                    "email": emailInputController.text,
                                  })
                                  .then((result) => {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                      title:
                                                          firstNameInputController
                                                                  .text +
                                                              "'s Tasks",
                                                      uid: currentUser.user.uid,
                                                    )),
                                            (_) => false),
                                        firstNameInputController.clear(),
                                        lastNameInputController.clear(),
                                        emailInputController.clear(),
                                        pwdInputController.clear(),
                                        confirmPwdInputController.clear()
                                      })
                                  .catchError((err) => print(err)))
                              .catchError((err) => print(err));
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Erro"),
                                  content: Text("As senhas não conferem."),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Fechar"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      }
                    },
                  ),
                  Text("Já possui uma conta?"),
                  FlatButton(
                    child: Text("Faça login aqui!"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ))));
  }
}

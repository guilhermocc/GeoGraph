import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/blocs/register.bloc.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc bloc = new RegisterBloc();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cadastro de Conta"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: bloc.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: bloc.registerFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Primeiro nome*'),
                          controller: bloc.firstNameInputController,
                          validator: (value) {
                            if (value.length < 3) {
                              return "Por favor insira um primeiro nome válido.";
                            }
                          },
                        ),
                        TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Segundo nome*'),
                            controller: bloc.lastNameInputController,
                            validator: (value) {
                              if (value.length < 3) {
                                return "Por favor insira um segundo nome válido.";
                              }
                            }),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email*'),
                          controller: bloc.emailInputController,
                          keyboardType: TextInputType.emailAddress,
                          validator: bloc.emailValidator,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Senha*'),
                          controller: bloc.passwordInputController,
                          obscureText: true,
                          validator: bloc.pwdValidator,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Confirmação de senha*',
                              hintText: "********"),
                          controller: bloc.confirmPasswordInputController,
                          obscureText: true,
                          validator: bloc.pwdValidator,
                        ),
                        RaisedButton(
                          child: Text("Criar Conta"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              // TODO It would be better to extract this logic
                              // and error handling to bloc class
                              bloc.createAccount(context).catchError((err) =>
                                  setState(() => bloc.isLoading = false));
                            });
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

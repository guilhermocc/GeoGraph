import 'package:flutter/material.dart';
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
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  )
                : SingleChildScrollView(
                    child: Form(
                    key: bloc.registerFormKey,
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
                                backgroundImage: NetworkImage(
                                  'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y'),
                                backgroundColor: Colors.transparent,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Primeiro nome*'),
                                controller: bloc.firstNameInputController,
                                validator: bloc.nameValidator,
                              ),
                              TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Sobrenome *'),
                                  controller: bloc.lastNameInputController,
                                  validator: bloc.nameValidator),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Email*'),
                                controller: bloc.emailInputController,
                                keyboardType: TextInputType.emailAddress,
                                validator: bloc.emailValidator,
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Senha*'),
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
                            ],
                          ),
                        ),
                        RaisedButton(
                          child: Text("Criar Conta"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              // TODO It would be better to extract this logic
                              // and error handling to bloc class
                              bloc.createAccount(context).catchError((err) {
                                setState(() {
                                  bloc.handleRegistrationError(err, context);
                                });
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ))));
  }
}

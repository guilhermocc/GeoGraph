import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/blocs/login.bloc.dart';
import 'package:location_permissions/location_permissions.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var bloc = new LoginBloc();

  @override
  initState()  {
    requestLocationPermission();
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
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )
                : SingleChildScrollView(
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
                            padding: EdgeInsets.only(top: 40, bottom: 15),
                            child: RaisedButton(
                                child: Text("Entrar"),
                                color: Theme.of(context).primaryColorDark,
                                textColor: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    // TODO It would be better to extract this logic
                                    // and error handling to bloc class
                                    bloc.login(context).catchError((err) {
                                      setState(() {
                                        bloc.handleLoginError(err, context);
                                      });
                                    });
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
                            child: Text('Ou'),
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
                            color: Theme.of(context).primaryColorDark,
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

  Future<void> requestLocationPermission() async {
    await LocationPermissions().requestPermissions();
  }
}

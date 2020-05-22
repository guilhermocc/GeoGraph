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
                    child: CircularProgressIndicator(),
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
                                    'https://scontent.fcgh10-1.fna.fbcdn.net/v/t1.0-9/95000440_1110826205943316_9215072197238849536_n.jpg?_nc_cat=101&_nc_sid=09cbfe&_nc_eui2=AeFZ_PUsfWSiLNJt80r7qnoKoDNo-8fk6Q2gM2j7x-TpDdAEvqKt-Rcrjlf0B-8-BG0Ov2Pq7lKRg4Vsa3UKTayw&_nc_ohc=LsycrnlcH1cAX_Df4q1&_nc_ht=scontent.fcgh10-1.fna&oh=2592e4bba2ae5f78b169e35d9ebfaa18&oe=5EEE2171'),
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
                                      labelText: 'Segundo nome*'),
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

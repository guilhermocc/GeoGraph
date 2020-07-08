import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geograph/blocs/enter_new_group.bloc.dart';
import 'package:geograph/blocs/login.bloc.dart';

class EnterNewGroupPage extends StatefulWidget {
  EnterNewGroupPage({Key key}) : super(key: key);

  @override
  _EnterNewGroupPageState createState() => _EnterNewGroupPageState();
}

class _EnterNewGroupPageState extends State<EnterNewGroupPage> {
  var bloc = new EnterNewGroupBloc();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Entrar em um novo grupo"),
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
                    key: bloc.enterGroupFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Identificador do grupo'),
                          controller: bloc.identifierInputController,
                          keyboardType: TextInputType.text,
                          validator: bloc.identifierValidator,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Senha do grupo', hintText: "********"),
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
                                    bloc.enterGroup(context).catchError((err) {
                                      setState(() {
                                        bloc.handleEnterGroupError(err, context);
                                      });
                                    });
                                  });
                                })),
                      ],
                    ),
                  ))));
  }
}

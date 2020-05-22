import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geograph/android/pages/home.dart';

class RegisterBloc {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController = new TextEditingController();
  TextEditingController lastNameInputController = new TextEditingController();
  TextEditingController emailInputController = new TextEditingController();
  TextEditingController passwordInputController = new TextEditingController();
  TextEditingController confirmPasswordInputController =
      new TextEditingController();
  bool isLoading = false;

  createAccount(BuildContext context) async {
    if (registerFormKey.currentState.validate()) {
      if (this.passwordInputController.text ==
          this.confirmPasswordInputController.text) {
        this.isLoading = true;
        AuthResult authResult = await createUserWithEmailAndPassword();
        await updateUserData(authResult);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      // TODO this thitle is not beign displayed on home page
                      title: this.firstNameInputController.text,
                      uid: authResult.user.uid,
                    )),
            (_) => false);
        this.firstNameInputController.clear();
        this.lastNameInputController.clear();
        this.emailInputController.clear();
        this.passwordInputController.clear();
        this.confirmPasswordInputController.clear();
      } else {
        showErrorDialog(context, "As senhas não conferem.");
      }
    }
  }

  createUserWithEmailAndPassword() async {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: this.emailInputController.text,
        password: this.passwordInputController.text);
  }

  showErrorDialog(BuildContext context, String textContent) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erro"),
            content: Text(textContent),
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

  updateUserData(AuthResult currentUser) async {
    return Firestore.instance
        .collection("users")
        .document(currentUser.user.uid)
        .setData({
      "uid": currentUser.user.uid,
      "fname": this.firstNameInputController.text,
      "surname": this.lastNameInputController.text,
      "email": this.emailInputController.text,
    });
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

  handleRegistrationError(PlatformException err, BuildContext context) {
    this.isLoading = false;
    if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
      this.showErrorDialog(context, "E-mail já está em uso");
    } else {
      {
        this.showErrorDialog(context, "Houve um erro ao criar a conta");
      }
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A Senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
  }

  String nameValidator(String value) {
    if (value.length < 3) {
      return "Por favor insira um segundo nome válido.";
    } else {
      return null;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geograph/android/pages/home.dart';
import 'package:geograph/android/pages/map.dart';
import 'package:geograph/blocs/user.bloc.dart';
import 'package:geograph/store/user/user.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UpdateGroupBloc {
  final GlobalKey<FormState> updateGroupFormKey = GlobalKey<FormState>();
  final UserBloc userBloc = UserBloc();

  TextEditingController identifierController = TextEditingController();
  TextEditingController groupTitleController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmationController = TextEditingController();
  TextEditingController currentPasswordConfirmationController = TextEditingController();


  bool isLoading = false;

  bool validateForm(BuildContext context, bool isChangingPassword, currentPasswordFromFirestore) {
    if (updateGroupFormKey.currentState.validate()) {
      if (isChangingPassword) {
        if (currentPasswordConfirmationController.text != currentPasswordFromFirestore) {
          showErrorDialog(context, "A senha atual não confere");
          return false;
        }
        else if(newPasswordConfirmationController.text != newPasswordController.text) {
          showErrorDialog(context, "As novas senhas informadas não conferem");
          return false;
        }
        return true;
      }
      return true;
    }
    return false;
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'A Senha deve ter ao menos 8 caracteres';
    } else {
      return null;
    }
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

  handleGroupCreationError(PlatformException err, BuildContext context) {
    this.isLoading = false;
    if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
      this.showErrorDialog(context, "E-mail já está em uso");
    } else {
      {
        this.showErrorDialog(context, "Houve um erro ao criar a conta");
      }
    }
  }

  navigateToGroupPage(
      DocumentSnapshot groupSnapShot, BuildContext context, User user) async {
    var groupData = groupSnapShot.data;
    List<String> membersUidList = List<String>.from(groupData["members"]
        .map((member) => member["uid"].documentID)
        .toList());
    List<dynamic> membersList = groupData["members"];

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(
                  userId: user.uid,
                  groupId: groupSnapShot.documentID,
                  groupTitle: groupSnapShot["title"],
                  groupDescription: groupSnapShot["description"],
                  membersUidList: membersUidList,
                  membersList: membersList,
                )));
  }

  Future<void> updateGroupInfo(String groupId, bool isChangingPassword) async {
    DocumentReference groupReference = Firestore.instance.collection("groups").document(groupId);
    groupReference.updateData(isChangingPassword? {
      "title": groupTitleController.text,
      "description": groupDescriptionController.text,
      "password": newPasswordController.text
    }: {
      "title": groupTitleController.text,
      "description": groupDescriptionController.text,
    });
  }


  String nameValidator(String value) {
    if (value.length < 3) {
      return "O nome do grupo deve possuir ao menos 3 caracteres";
    } else if (value.length > 18) {
      return "O nome do grupo deve possuir no máximo 18 caracteres";
    } else {
      return null;
    }
  }

  String descriptionValidator(String value) {
    if (value.length < 10) {
      return "A descrição do grupo deve possuir ao menos 10 caracteres";
    } else if (value.length > 100) {
      return "A descrição do grupo deve possuir no máximo 100 caracteres";
    } else {
      return null;
    }
  }
}

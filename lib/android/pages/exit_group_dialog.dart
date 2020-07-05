import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ExitGroupDialog extends StatefulWidget {
  ExitGroupDialog(
      {Key key,
      this.memberUid,
      this.groupUid})
      : super(key: key);

  final memberUid;
  final groupUid;

  @override
  _ExitGroupDialogState createState() => _ExitGroupDialogState();
}

class _ExitGroupDialogState extends State<ExitGroupDialog> {
  bool exitSuccessful = true;
  bool triedToExit = false;

  @override
  Widget build(BuildContext context) {
    return triedToExit && !exitSuccessful? Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Erro ao sair do grupo, tente novamente",
                    style: TextStyle(
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 50),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    color: Theme.of(context)
                        .primaryColorDark,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Fechar',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ): Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Deseja confirmar a saída do grupo?",
                    style: TextStyle(
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 50),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    color: Theme.of(context)
                        .primaryColorDark,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Não',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    color: Theme.of(context)
                        .primaryColorDark,
                    onPressed: () async {
                      bool exitStatus = true;
                      await exitGroup()
                          .catchError((error) {
                        exitStatus = false;
                      });
                      setState(() {
                        triedToExit = true;
                        exitSuccessful = exitStatus;
                      });
                    },
                    child: Text(
                      'Sim',
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exitGroup() async {
    CollectionReference groupReference =
    Firestore.instance.collection("groups");
    DocumentReference userReference =
    Firestore.instance.collection("users").document(widget.memberUid);
    DocumentReference groupDocumentReference =
    Firestore.instance.collection("groups").document(widget.groupUid);

    DocumentSnapshot snapshot = await groupDocumentReference.get();
    List<dynamic> members = snapshot.data["members"];
    members.removeWhere((member) => member["uid"].documentID == widget.memberUid);
    groupDocumentReference.updateData({"members": members});
  }

}

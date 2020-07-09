import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PersonDialog extends StatefulWidget {
  PersonDialog(
      {Key key,
      this.placemark,
      this.formatedDistance,
      this.username,
      this.memberUid,
      this.memberType,
      this.groupUid,
      this.controllerUserType,
      this.controllerUserUid,
      this.positionValid
      })
      : super(key: key);

  final String username;
  final Placemark placemark;
  final String formatedDistance;
  final String memberUid;
  final String memberType;
  final groupUid;
  final String controllerUserType;
  final String controllerUserUid;
  bool positionValid = true;

  @override
  _PersonDialogState createState() => _PersonDialogState();
}

class _PersonDialogState extends State<PersonDialog> {
  bool deleteSuccessful = true;
  bool triedToDelete = false;
  bool isPromotingAdmin = false;
  bool triedToPromote = false;
  bool promotingSuccessful = true;
  bool isDeletingMember = false;

  @override
  Widget build(BuildContext context) {
    if (triedToPromote) {
      return Dialog(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      promotingSuccessful
                          ? 'Membro promovido a administrador com sucesso.'
                          : "Erro ao promover membro, tente novamente.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Fechar',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (triedToDelete) {
      return Dialog(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      deleteSuccessful
                          ? 'Membro removido do grupo com sucesso.'
                          : "Erro ao remover membro do grupo, tente novamente.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Fechar',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isPromotingAdmin) {
      return Dialog(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Deseja tornar este membro um administrador do grupo?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Não',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () async {
                        bool promotionSate = true;
                        await promoteAdminGroupMember().catchError((error) {
                          promotionSate = false;
                        });
                        setState(() {
                          triedToPromote = true;
                          isPromotingAdmin = false;
                          promotingSuccessful = promotionSate;
                        });
                      },
                      child: Text(
                        'Sim',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isDeletingMember) {
      return Dialog(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Deseja remover este membro do grupo?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Não',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () async {
                        bool deleteStatus = true;
                        await removeGroupMember().catchError((error) {
                          deleteStatus = false;
                        });
                        setState(() {
                          triedToDelete = true;
                          deleteSuccessful = deleteStatus;
                          isDeletingMember = false;
                        });
                      },
                      child: Text(
                        'Sim',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
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
    return Dialog(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nome: ${widget.username}',
                    style: TextStyle(color: Colors.black),
                  ),
                  widget.placemark.administrativeArea != ""
                      ? Text(
                          'Estado: ${widget.placemark.administrativeArea}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  widget.placemark.subAdministrativeArea != ""
                      ? Text(
                          'Cidade: ${widget.placemark.subAdministrativeArea}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  widget.placemark.subLocality != ""
                      ? Text(
                          'Bairro: ${widget.placemark.subLocality}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  widget.placemark.thoroughfare != ""
                      ? Text(
                          'Rua: ${widget.placemark.thoroughfare}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  widget.placemark.subThoroughfare != ""
                      ? Text(
                          'Número: ${widget.placemark.subThoroughfare}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  widget.formatedDistance != "" && widget.positionValid
                      ? Text(
                          'Distância: ${widget.formatedDistance}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
              child: Column(
                children: <Widget>[
                  widget.controllerUserType == "admin"
                      ? Container()
                      : RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Fechar',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                  widget.controllerUserType == "admin" && widget.memberUid != widget.controllerUserUid
                      ? RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () {
                            setState(() {
                              isDeletingMember = true;
                            });
                          },
                          child: Text(
                            'Excluir membro',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        )
                      : Container(),
                  widget.controllerUserType == "admin" &&
                          widget.memberType == "neutral"
                      ? RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () {
                            setState(() {
                              isPromotingAdmin = true;
                            });
                          },
                          child: Text(
                            'Tornar administrador',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> removeGroupMember() async {
    CollectionReference groupReference =
        Firestore.instance.collection("groups");
    DocumentReference userReference =
        Firestore.instance.collection("users").document(widget.memberUid);
    DocumentReference groupDocumentReference =
        Firestore.instance.collection("groups").document(widget.groupUid);

    DocumentSnapshot snapshot = await groupDocumentReference.get();
    List<dynamic> members = snapshot.data["members"];
    members
        .removeWhere((member) => member["uid"].documentID == widget.memberUid);

    groupDocumentReference.updateData({"members": members});
  }

  Future<void> promoteAdminGroupMember() async {
    CollectionReference groupReference =
        Firestore.instance.collection("groups");
    DocumentReference userReference =
        Firestore.instance.collection("users").document(widget.memberUid);
    DocumentReference groupDocumentReference =
        Firestore.instance.collection("groups").document(widget.groupUid);

    DocumentSnapshot snapshot = await groupDocumentReference.get();
    List<dynamic> members = snapshot.data["members"];
    int memberIndex = members.lastIndexWhere(
        (member) => member["uid"].documentID == widget.memberUid);
    members[memberIndex]["type"] = "admin";
    groupDocumentReference.updateData({"members": members});
  }
}

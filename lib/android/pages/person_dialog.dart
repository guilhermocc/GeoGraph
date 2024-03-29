import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      this.positionValid})
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
    return AlertDialog(
      title: Text(
        '${widget.username}',
        style: TextStyle( fontSize: 20 ,color: Theme.of(context).primaryColorDark),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      content: Container(
        height: 300.0,
        width: 300.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.placemark.administrativeArea != ""
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: 'Estado: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 17),
                            ),
                            TextSpan(
                              text: '${widget.placemark.administrativeArea}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ])),
                          Divider()
                        ])
                      : Container(),
                  widget.placemark.subAdministrativeArea != ""
                      ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: 'Cidade: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 17),
                            ),
                            TextSpan(
                              text: '${widget.placemark.subAdministrativeArea}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ])),
                          Divider()
                        ])
                      : Container(),
                  widget.placemark.subLocality != ""
                      ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: 'Bairro: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 17),
                            ),
                            TextSpan(
                              text: '${widget.placemark.subLocality}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ])),
                          Divider()
                        ])
                      : Container(),
                  widget.placemark.thoroughfare != ""
                      ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 17),
                              text: 'Rua: ',
                            ),
                            TextSpan(
                              text: '${widget.placemark.thoroughfare}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ])),
                          Divider()
                        ])
                      : Container(),
                  widget.placemark.subThoroughfare != ""
                      ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: 'Número: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 17),
                            ),
                            TextSpan(
                              text: '${widget.placemark.subThoroughfare}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ])),
                          Divider()
                        ])
                      : Container(),
                  widget.formatedDistance != "" && widget.positionValid
                      ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: 'Distância: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 17),
                            ),
                            TextSpan(
                              text: '${widget.formatedDistance}',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ])),
                          Divider()
                        ])
                      : Container(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
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
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
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
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
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
    CollectionReference groupReference = Firestore.instance.collection("groups");
    DocumentReference userReference = Firestore.instance.collection("users").document(widget.memberUid);
    DocumentReference groupDocumentReference = Firestore.instance.collection("groups").document(widget.groupUid);

    DocumentSnapshot snapshot = await groupDocumentReference.get();
    List<dynamic> members = snapshot.data["members"];
    members.removeWhere((member) => member["uid"].documentID == widget.memberUid);

    groupDocumentReference.updateData({"members": members});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PersonDialog extends StatelessWidget {
  PersonDialog(
      {Key key,
      this.placemark,
      this.formatedDistance,
      this.username,
      this.memberUid,
      this.groupUid,
      this.controllerUserType})
      : super(key: key);

  final String username;
  final Placemark placemark;
  final String formatedDistance;
  final memberUid;
  final groupUid;
  final String controllerUserType;

  Future<void> removeGroupMember() async {
    CollectionReference groupReference =
        Firestore.instance.collection("groups");
    DocumentReference userReference =
        Firestore.instance.collection("users").document(memberUid);
    DocumentReference groupDocumentReference =
        Firestore.instance.collection("groups").document(groupUid);

    DocumentSnapshot snapshot = await groupDocumentReference.get();
    List<dynamic> members = snapshot.data["members"];
    members.removeWhere((member) => member["uid"].documentID == memberUid);

    groupDocumentReference.updateData({"members": members});

  }

  @override
  Widget build(BuildContext context) {
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
                    'Nome: ${username}',
                    style: TextStyle(color: Colors.black),
                  ),
                  placemark.administrativeArea != ""
                      ? Text(
                          'Estado: ${placemark.administrativeArea}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  placemark.subAdministrativeArea != ""
                      ? Text(
                          'Cidade: ${placemark.subAdministrativeArea}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  placemark.subLocality != ""
                      ? Text(
                          'Bairro: ${placemark.subLocality}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  placemark.thoroughfare != ""
                      ? Text(
                          'Rua: ${placemark.thoroughfare}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  placemark.subThoroughfare != ""
                      ? Text(
                          'Número: ${placemark.subThoroughfare}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
                  formatedDistance != ""
                      ? Text(
                          'Distância: ${formatedDistance}',
                          style: TextStyle(color: Colors.black),
                        )
                      : Container(),
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
                  controllerUserType == "admin"
                      ? RaisedButton(
                          color: Theme.of(context).primaryColorLight,
                          onPressed: () async {
                            await removeGroupMember();
                          },
                          child: Text(
                            'Excluir membro',
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
}

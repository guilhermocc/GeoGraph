import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PersonDialog extends StatelessWidget {
  PersonDialog({Key key, this.placemark, this.formatedDistance, this.username})
      : super(key: key);

  final username;
  final placemark;
  final formatedDistance;

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
                mainAxisAlignment: MainAxisAlignment.center,
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

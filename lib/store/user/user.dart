import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

part 'user.g.dart';

class User = _User with _$User;

abstract class _User with Store {
  @observable
  DocumentReference documentReference;

  @action
  void setDocumentReference(DocumentReference reference) {
    documentReference = reference;
  }

  @observable
  String uid = "";

  @action
  void setUid(String userUid) {
    uid = userUid;
  }

  @observable
  String firstName = "";

  @action
  void setFirstName(String name) {
    firstName = name;
  }

  @observable
  String lastName = "";

  @action
  void setLastName(String name) {
    lastName = name;
  }

  @observable
  String email = "";

  @action
  void setEmail(String userEmail) {
    email = userEmail;
  }
}

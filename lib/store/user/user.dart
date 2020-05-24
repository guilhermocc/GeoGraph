import 'package:mobx/mobx.dart';

part 'user.g.dart';

class User = _User with _$User;

abstract class _User with Store {
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

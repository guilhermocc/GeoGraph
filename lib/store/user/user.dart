import 'package:mobx/mobx.dart';

part 'user.g.dart';

class User = _User with _$User;

abstract class _User with Store {
  @observable
  String firstName;

  @observable
  String lastName;

  @observable
  String email;

  @action
  void setFirstName(String name) {
    firstName = name;
  }

  @action
  void setLastName(String name) {
    lastName = name;
  }

  @action
  void setEmail(String userEmail) {
    email = userEmail;
  }
}

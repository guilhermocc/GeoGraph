// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$User on _User, Store {
  final _$uidAtom = Atom(name: '_User.uid');

  @override
  String get uid {
    _$uidAtom.reportRead();
    return super.uid;
  }

  @override
  set uid(String value) {
    _$uidAtom.reportWrite(value, super.uid, () {
      super.uid = value;
    });
  }

  final _$firstNameAtom = Atom(name: '_User.firstName');

  @override
  String get firstName {
    _$firstNameAtom.reportRead();
    return super.firstName;
  }

  @override
  set firstName(String value) {
    _$firstNameAtom.reportWrite(value, super.firstName, () {
      super.firstName = value;
    });
  }

  final _$lastNameAtom = Atom(name: '_User.lastName');

  @override
  String get lastName {
    _$lastNameAtom.reportRead();
    return super.lastName;
  }

  @override
  set lastName(String value) {
    _$lastNameAtom.reportWrite(value, super.lastName, () {
      super.lastName = value;
    });
  }

  final _$emailAtom = Atom(name: '_User.email');

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  final _$_UserActionController = ActionController(name: '_User');

  @override
  void setUid(String userUid) {
    final _$actionInfo =
        _$_UserActionController.startAction(name: '_User.setUid');
    try {
      return super.setUid(userUid);
    } finally {
      _$_UserActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFirstName(String name) {
    final _$actionInfo =
        _$_UserActionController.startAction(name: '_User.setFirstName');
    try {
      return super.setFirstName(name);
    } finally {
      _$_UserActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastName(String name) {
    final _$actionInfo =
        _$_UserActionController.startAction(name: '_User.setLastName');
    try {
      return super.setLastName(name);
    } finally {
      _$_UserActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String userEmail) {
    final _$actionInfo =
        _$_UserActionController.startAction(name: '_User.setEmail');
    try {
      return super.setEmail(userEmail);
    } finally {
      _$_UserActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
uid: ${uid},
firstName: ${firstName},
lastName: ${lastName},
email: ${email}
    ''';
  }
}

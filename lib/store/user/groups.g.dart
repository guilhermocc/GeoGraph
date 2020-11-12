// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Groups on _Groups, Store {
  final _$groupsReferencesAtom = Atom(name: '_Groups.groupsReferences');

  @override
  Set<DocumentReference> get groupsReferences {
    _$groupsReferencesAtom.reportRead();
    return super.groupsReferences;
  }

  @override
  set groupsReferences(Set<DocumentReference> value) {
    _$groupsReferencesAtom.reportWrite(value, super.groupsReferences, () {
      super.groupsReferences = value;
    });
  }

  final _$_GroupsActionController = ActionController(name: '_Groups');

  @override
  void loadGroupReferences(Set<DocumentReference> references) {
    final _$actionInfo = _$_GroupsActionController.startAction(
        name: '_Groups.loadGroupReferences');
    try {
      return super.loadGroupReferences(references);
    } finally {
      _$_GroupsActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addGroupReference(DocumentReference reference) {
    final _$actionInfo = _$_GroupsActionController.startAction(
        name: '_Groups.addGroupReference');
    try {
      return super.addGroupReference(reference);
    } finally {
      _$_GroupsActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeGroupReference(DocumentReference reference) {
    final _$actionInfo = _$_GroupsActionController.startAction(
        name: '_Groups.removeGroupReference');
    try {
      return super.removeGroupReference(reference);
    } finally {
      _$_GroupsActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
groupsReferences: ${groupsReferences}
    ''';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

part 'groups.g.dart';

class Groups = _Groups with _$Groups;

abstract class _Groups with Store {
  @observable
  Set<DocumentReference> groupsReferences = Set();

  @action
  void loadGroupReferences(Set<DocumentReference> references) {
    groupsReferences = references;
  }

  @action
  void addGroupReference(DocumentReference reference) {
    groupsReferences.add(reference);
  }

  @action
  void removeGroupReference(DocumentReference reference) {
    groupsReferences.remove(reference);
  }
}

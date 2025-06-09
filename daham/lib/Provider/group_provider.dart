import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/group.dart';

class GroupProvider extends ChangeNotifier {
  List<Group> groups = [];

  Future<void> fetchGroups() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('groups').get();
    groups = snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
    notifyListeners();
  }

  Future<void> createGroup(Group group) async {
    groups.add(group);
    notifyListeners();
  }

  Future<void> joinGroup(String groupId, String userId) async {
    final groupDoc = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId);
    await groupDoc.update({
      'members': FieldValue.arrayUnion([userId]),
    });
    // 로컬 상태도 갱신
    await fetchGroups();
  }

  // 초대코드로 그룹 찾기
  Future<Group?> findByInviteCode(String code) async {
    final query =
        await FirebaseFirestore.instance
            .collection('groups')
            .where('inviteCode', isEqualTo: code)
            .get();
    if (query.docs.isNotEmpty) {
      return Group.fromMap(query.docs.first.data());
    }
    return null;
  }

  // 그룹 이름으로 검색
  Group? searchGroupByName(String name) {
    try {
      return groups.firstWhere((g) => g.title == name);
    } catch (_) {
      return null;
    }
  }
}

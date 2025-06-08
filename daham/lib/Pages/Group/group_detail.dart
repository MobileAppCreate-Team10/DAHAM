import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Pages/Group/group_edit.dart';
import 'package:daham/Data/task.dart';
import 'task_create.dart';
import 'task_detail.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _fetchUserNames();
  }

  Future<void> _fetchUserNames() async {
    final members = widget.group.members;
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userNames = <String, String>{};
    for (final uid in members) {
      final doc = await usersRef.doc(uid).get();
      userNames[uid] = doc.data()?['userName'] ?? uid;
    }
    setState(() {
      _userNames = userNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.group.id)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.data() == null) {
          return const Center(child: Text('이 그룹은 삭제 되었습니다.'));
        }

        final group = Group.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
        );
        final isMember = group.members.contains(currentUserId);
        final isOwner = group.ownerId == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: Text(group.title),
            actions: [
              if (isOwner)
                // 그룹 owner만 편집 및 삭제 가능
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => GroupEditModal(group: group),
                    );
                    setState(() {});
                  },
                ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('그룹 삭제'),
                          content: const Text('정말로 이 그룹을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(group.id)
                        .delete();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.isPrivate && group.inviteCode != null)
                  Card(
                    color: Colors.yellow[100],
                    child: ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: Text('초대코드: ${group.inviteCode!}'),
                      subtitle: const Text('이 코드를 공유해 그룹에 초대하세요.'),
                    ),
                  ),
                Card(
                  child: ListTile(
                    title: Text(group.title),
                    subtitle: Text('현재 ${group.members.length}명 참여 중'),
                    trailing: CircleAvatar(
                      child: Text('${(group.progress * 100).toInt()}%'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isMember) ...[
                  const Text('👥 그룹 참여자'),
                  ...group.members.map(
                    (m) => ListTile(title: Text(_userNames[m] ?? m)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        currentUserId == null
                            ? null
                            : () async {
                              await FirebaseFirestore.instance
                                  .collection('groups')
                                  .doc(group.id)
                                  .update({
                                    'members': FieldValue.arrayUnion([
                                      currentUserId,
                                    ]),
                                  });
                              setState(() {
                                group.members.add(currentUserId!);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('그룹에 가입되었습니다!')),
                              );
                            },
                    child: const Text('그룹 가입하기'),
                  ),
                ] else ...[
                  const Text(
                    '📋 그룹 과제 목록',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child:
                        group.tasks.isEmpty
                            ? const Center(child: Text('등록된 과제가 없습니다.'))
                            : ListView.builder(
                              itemCount: group.tasks.length,
                              itemBuilder: (context, taskIdx) {
                                final task = group.tasks[taskIdx];
                                final myProgress =
                                    task.memberProgress[currentUserId] ?? 0.0;
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    title: Text(task.title),
                                    subtitle: Text('카테고리: ${task.category}'),
                                    trailing: Text(
                                      '${(myProgress * 100).toInt()}%',
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TaskDetailPage(
                                                task: task,
                                                group: group,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ],
            ),
          ),
          floatingActionButton:
              isMember
                  ? FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => TaskCreateModal(group: group),
                      );
                      setState(() {});
                    },
                  )
                  : null,
        );
      },
    );
  }
}

// group의 전체 진행률 계산 함수
double calculateGroupProgress(Group group) {
  final tasks = group.tasks;
  if (tasks.isEmpty) return 0.0;
  final totalProgress = tasks
      .map((task) => task.memberProgress.values.fold(0.0, (a, b) => a + b))
      .fold(0.0, (a, b) => a + b);
  final totalCount = tasks
      .map((task) => task.memberProgress.length)
      .fold(0, (a, b) => a + b);
  return totalCount == 0 ? 0.0 : totalProgress / totalCount;
}

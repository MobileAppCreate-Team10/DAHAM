import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/group.dart';
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
    final group = widget.group;
    final isMember = group.members.contains(currentUserId);

    return Scaffold(
      appBar: AppBar(title: Text(group.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text(
              '📋 그룹 과제 목록',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: group.tasks.length,
                itemBuilder: (context, taskIdx) {
                  final task = group.tasks[taskIdx];
                  final myProgress = task.memberProgress[currentUserId] ?? 0.0;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => TaskDetailPage(task: task, group: group),
                          ),
                        );
                        setState(() {});
                      },
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('카테고리: ${task.category}'),
                          Text(
                            '진행률: ${(myProgress * 100).toStringAsFixed(0)}%',
                          ),
                          Slider(
                            value: myProgress,
                            onChanged: null,
                            min: 0,
                            max: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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

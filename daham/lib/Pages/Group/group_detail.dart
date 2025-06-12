import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Func/function_img.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Pages/Group/group_edit.dart';
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
    final theme = Theme.of(context);
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
            backgroundColor: Colors.indigo[50],
            elevation: 0,
            actions: [
              if (isOwner) ...[
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
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 상단 그룹 정보 카드
                Container(
                  width: double.infinity,
                  color: Colors.indigo[50],
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        group.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '현재 ${group.members.length}명 참여 중',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.indigo[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 진행률 ProgressBar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.show_chart, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: group.progress,
                              minHeight: 10,
                              backgroundColor: Colors.indigo[100],
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(group.progress * 100).toInt()}%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 멤버 이니셜 아바타
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: group.members.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final uid = group.members[idx];
                            final name = _userNames[uid] ?? uid;
                            return CircleAvatar(
                              backgroundColor: Colors.indigo[200],
                              child: Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (group.isPrivate && group.inviteCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Card(
                            color: Colors.yellow[100],
                            child: ListTile(
                              leading: const Icon(Icons.vpn_key),
                              title: Text('초대코드: ${group.inviteCode!}'),
                              subtitle: const Text('이 코드를 공유해 그룹에 초대하세요.'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      isMember
                          ? _buildTaskList(context, group)
                          : _buildMemberList(context, group),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          floatingActionButton:
              isMember
                  ? FloatingActionButton(
                    backgroundColor: Colors.indigo[100],
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

  Widget _buildMemberList(BuildContext context, Group group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👥 그룹 참여자', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children:
                group.members
                    .map(
                      (m) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo[200],
                          child: Text(
                            (_userNames[m] ?? m).isNotEmpty
                                ? (_userNames[m] ?? m)[0]
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_userNames[m] ?? m),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.group_add),
            label: const Text('그룹 가입하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed:
                currentUserId == null
                    ? null
                    : () async {
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(group.id)
                          .update({
                            'members': FieldValue.arrayUnion([currentUserId]),
                          });
                      setState(() {
                        group.members.add(currentUserId!);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('그룹에 가입되었습니다!')),
                      );
                    },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, Group group) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildReceiverImage(group.id, currentUserId ?? ''), // 여기에 추가!
        const Text(
          '📋 그룹 과제 목록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        group.tasks.isEmpty
            ? const Center(child: Text('등록된 과제가 없습니다.'))
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, taskIdx) {
                final task = group.tasks[taskIdx];
                final myProgress = task.memberProgress[currentUserId] ?? 0.0;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: Icon(Icons.assignment, color: Colors.indigo[700]),
                    ),
                    title: Text(task.title, style: theme.textTheme.titleMedium),
                    subtitle: Text('카테고리: ${task.category}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(myProgress * 100).toInt()}%',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.indigo[900],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: LinearProgressIndicator(
                            value: myProgress,
                            minHeight: 6,
                            backgroundColor: Colors.indigo[50],
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TaskDetailPage(task: task, group: group),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ],
    );
  }
}

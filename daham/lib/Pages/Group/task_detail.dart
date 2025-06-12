import 'package:daham/Pages/Group/task_edit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daham/Data/task.dart';
import 'package:daham/Data/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final Group group;

  const TaskDetailPage({super.key, required this.task, required this.group});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  double? _sliderValue;
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  String? _selectedMemberId;
  Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.task.memberProgress[currentUserId] ?? 0.0;
    _fetchUserNames();
  }

  Future<void> _fetchUserNames() async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userNames = <String, String>{};
    for (final uid in widget.group.members) {
      final doc = await usersRef.doc(uid).get();
      userNames[uid] = doc.data()?['userName'] ?? uid;
    }
    setState(() {
      _userNames = userNames;
    });
  }

  Future<void> _updateProgress() async {
    if (currentUserId != null) {
      setState(() {
        widget.task.memberProgress[currentUserId!] = _sliderValue ?? 0.0;
        widget.group.progress = calculateGroupProgress(widget.group);
      });
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .update({
            'tasks': widget.group.tasks.map((t) => t.toMap()).toList(),
            'progress': widget.group.progress,
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('진행률이 저장되었습니다')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final group = widget.group;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        backgroundColor: Colors.teal[50],
        elevation: 0,
        actions: [
          if (task.creatorId == currentUserId) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TaskEditModal(task: task, group: group),
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
                        title: const Text('과제 삭제'),
                        content: const Text('정말로 이 과제를 삭제하시겠습니까?'),
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
                  group.tasks.removeWhere((t) => t.id == task.id);
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(group.id)
                      .update({
                        'tasks': group.tasks.map((t) => t.toMap()).toList(),
                      });
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 과제 정보 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            '카테고리: ${task.category}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.subject, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Text(
                            '과목: ${task.subject}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '마감일: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : '미지정'}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 진행률 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📈 내 진행률',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _sliderValue ?? 0.0,
                        min: 0,
                        max: 1,
                        divisions: 100,
                        label: '${((_sliderValue ?? 0.0) * 100).toInt()}%',
                        onChanged:
                            (value) => setState(() => _sliderValue = value),
                      ),
                      const SizedBox(height: 12),
                      // 멤버 선택 드롭다운 (userName 매핑)
                      DropdownButtonFormField<String>(
                        value: _selectedMemberId,
                        hint: const Text('멤버 선택'),
                        items:
                            widget.group.members.map((uid) {
                              final name = _userNames[uid] ?? uid;
                              return DropdownMenuItem(
                                value: uid,
                                child: Text(
                                  uid == currentUserId ? '나 (본인)' : name,
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedMemberId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // 종이비행기 버튼 (Icons.send 사용)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                          label: const Text('종이비행기 보내기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed:
                              _selectedMemberId == null
                                  ? null
                                  : () async {
                                    final name =
                                        _userNames[_selectedMemberId!] ??
                                        _selectedMemberId!;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$name님에게 종이비행기를 보냈습니다!'),
                                      ),
                                    );
                                  },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 기존 '진행률 저장' 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('진행률 저장'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _updateProgress,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

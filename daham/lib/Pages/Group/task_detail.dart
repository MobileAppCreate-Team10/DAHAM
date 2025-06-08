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

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.task.memberProgress[currentUserId] ?? 0.0;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject: ${task.subject}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Category: ${task.category}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Due Date: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : '미지정'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '📈 내 진행률',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _sliderValue ?? 0.0,
              min: 0,
              max: 1,
              divisions: 100,
              label: '${((_sliderValue ?? 0.0) * 100).toInt()}%',
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
            ElevatedButton(
              onPressed: _updateProgress,
              child: const Text('진행률 저장'),
            ),
          ],
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

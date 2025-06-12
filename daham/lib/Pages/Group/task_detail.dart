import 'dart:io';

import 'package:daham/Pages/Group/task_edit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daham/Data/task.dart';
import 'package:daham/Data/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final Group group;

  const TaskDetailPage({super.key, required this.task, required this.group});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  double? _sliderValue;
  File? _selectedImage;
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

  Future<void> _markComplete() async {
    if (currentUserId != null) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    }
  }

  Future<void> _submitImage() async {
    final selectedUserId = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('누구에게 보낼까요?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...widget.group.memberInfo.entries.map((entry) {
              final userId = entry.key;
              final userName = entry.value['name'] ?? '이름 없음';
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(userName),
                onTap: () => Navigator.pop(context, userId),
              );
            }).toList(),
          ],
        );
      },
    );

    if (selectedUserId != null) {
      final userName = widget.group.memberInfo[selectedUserId]?['name'] ?? '알 수 없음';

      // TODO: 실제 Firestore 전송 or Storage 업로드 로직 추가 가능

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName 님에게 사진을 보냈습니다!')),
        );
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
                  builder: (context) => AlertDialog(
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
            Text('Subject: ${task.subject}', style: const TextStyle(fontSize: 16)),
            Text('Category: ${task.category}', style: const TextStyle(fontSize: 16)),
            Text(
              'Due Date: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : '미지정'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text('📈 내 진행률', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: (_sliderValue == 1.0) ? _markComplete : null,
                child: const Text('🎉 과제 완료'),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 24),
              Image.file(_selectedImage!, height: 200),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: _submitImage,
                  child: const Text('📤 보내기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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

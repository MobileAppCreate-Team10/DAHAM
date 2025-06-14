import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Data/task.dart';

class TaskCreateModal extends StatefulWidget {
  final Group group;

  const TaskCreateModal({super.key, required this.group});

  @override
  State<TaskCreateModal> createState() => _TaskCreateModalState();
}

class _TaskCreateModalState extends State<TaskCreateModal> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _categoryController = TextEditingController();

  Map<String, String> _userNames = {};
  final Set<String> _selectedUserIds = {};

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
      userNames[uid] = doc.data()?['userName'] ?? 'Unknown User';
    }
    setState(() {
      _userNames = userNames;
    });
  }

  bool _selectAll = false;
  DateTime? _selectedDueDate;

  @override
  Widget build(BuildContext context) {
    final members = widget.group.members;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '과제 추가',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '과제 이름'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: '수업 이름'),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: '카테고리'),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('마감 날짜'),
                  TextButton(
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selected != null) {
                        setState(() => _selectedDueDate = selected);
                      }
                    },
                    child: Text(
                      _selectedDueDate == null
                          ? '날짜 선택'
                          : DateFormat('yyyy-MM-dd').format(_selectedDueDate!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (checked) {
                      setState(() {
                        _selectAll = checked ?? false;
                        if (_selectAll) {
                          _selectedUserIds.addAll(members);
                        } else {
                          _selectedUserIds.clear();
                        }
                      });
                    },
                  ),
                  const Text('전체 선택'),
                ],
              ),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('참여할 멤버'),
              ),
              ...members.map((userId) {
                return CheckboxListTile(
                  value: _selectedUserIds.contains(userId),
                  title: Text(_userNames[userId] ?? '불러오는 중'),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedUserIds.add(userId);
                      } else {
                        _selectedUserIds.remove(userId);
                      }
                      // 전체선택 상태 동기화
                      _selectAll = _selectedUserIds.length == members.length;
                    });
                  },
                );
              }),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  final newTask = Task(
                    id: const Uuid().v4(),
                    title: _titleController.text,
                    subject: _subjectController.text,
                    category: _categoryController.text,
                    dueDate: _selectedDueDate,
                    memberProgress: {for (var id in _selectedUserIds) id: 0.0},
                    creatorId: currentUserId,
                  );
                  widget.group.tasks.add(newTask);

                  // Firestore에 tasks 업데이트
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.group.id)
                      .update({
                        'tasks':
                            widget.group.tasks.map((t) => t.toMap()).toList(),
                      });

                  if (mounted) Navigator.pop(context);
                },
                child: const Text('과제 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
  final Set<String> _selectedUserIds = {};

  @override
  Widget build(BuildContext context) {
    final members = widget.group.members;

    return Padding(
      padding: MediaQuery.of(context).viewInsets, // 키보드 올라도 잘 보이게
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
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('참여할 멤버'),
              ),
              ...members.map((userId) {
                return CheckboxListTile(
                  value: _selectedUserIds.contains(userId),
                  title: Text(userId),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedUserIds.add(userId);
                      } else {
                        _selectedUserIds.remove(userId);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final newTask = Task(
                    id: const Uuid().v4(),
                    title: _titleController.text,
                    subject: _subjectController.text,
                    memberProgress: {for (var id in _selectedUserIds) id: 0.0},
                  );
                  widget.group.tasks.add(newTask);
                  Navigator.pop(context); // 닫기
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

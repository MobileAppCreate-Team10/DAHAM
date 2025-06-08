import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Data/task.dart';
import 'package:daham/Data/group.dart';
import 'package:intl/intl.dart';

class TaskEditModal extends StatefulWidget {
  final Task task;
  final Group group;
  const TaskEditModal({super.key, required this.task, required this.group});

  @override
  State<TaskEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TaskEditModal> {
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late TextEditingController _categoryController;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _subjectController = TextEditingController(text: widget.task.subject);
    _categoryController = TextEditingController(text: widget.task.category);
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '과제 정보 수정',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '과제 이름'),
            ),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: '수업 이름'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: '카테고리'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('마감 날짜'),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _selectedDueDate = picked);
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
            ElevatedButton(
              onPressed: () async {
                widget.task.title = _titleController.text;
                widget.task.subject = _subjectController.text;
                widget.task.category = _categoryController.text;
                widget.task.dueDate = _selectedDueDate;
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.group.id)
                    .update({
                      'tasks':
                          widget.group.tasks.map((t) => t.toMap()).toList(),
                    });
                if (mounted) Navigator.pop(context);
              },
              child: const Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}

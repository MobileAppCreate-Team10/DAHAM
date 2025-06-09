import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Provider/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:provider/provider.dart';

const List<DropdownMenuItem<String>> priority = [
  DropdownMenuItem(value: 'High', child: Text('High')),
  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
  DropdownMenuItem(value: 'Low', child: Text('Low')),
];

void showTodoDialog({
  required BuildContext context,
  Map<String, dynamic>? json,
}) {
  Map<String, dynamic> result = {};

  AwesomeDialog(
    context: context,
    dialogType: DialogType.question,
    body: _TodoDialogContent(
      json: json ?? {},
      onChanged: (value) {
        result = value;
      },
    ),
    btnOkOnPress: () {
      // OK 버튼에서 저장
      Provider.of<TodoState>(
        context,
        listen: false,
      ).addTodoinUser(context, result);
    },
    btnCancelOnPress: () {},
  ).show();
}

class _TodoDialogContent extends StatefulWidget {
  final Map<String, dynamic> json;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const _TodoDialogContent({required this.json, required this.onChanged});

  @override
  State<_TodoDialogContent> createState() => _TodoDialogContentState();
}

class _TodoDialogContentState extends State<_TodoDialogContent> {
  late TextEditingController _taskController;
  late TextEditingController _dueDateController;
  String? _selectedPriority;
  late Map<String, dynamic> _details;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.json['task'] ?? '');
    _dueDateController = TextEditingController(
      text: widget.json['due_date'] ?? '',
    );
    _selectedPriority = widget.json['priority'] ?? priority[1].value;
    _details = widget.json['details'] ?? {};
    _notifyParent();
  }

  void _notifyParent() {
    widget.onChanged({
      'task': _taskController.text,
      'due_date': _dueDateController.text,
      'priority': _selectedPriority,
      'details': _details,
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(labelText: 'Task'),
                    onChanged: (_) => _notifyParent(),
                  ),
                ),
              ),
              SizedBox(width: 20),
              DueDateSector(context),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 120,
            child: FormBuilderDropdown<String>(
              name: '우선순위',
              items: priority,
              initialValue: _selectedPriority,
              onChanged: (val) {
                setState(() {
                  _selectedPriority = val;
                  _notifyParent();
                });
              },
              decoration: const InputDecoration(labelText: '우선순위'),
            ),
          ),
          Visibility(
            child: DetailSection(
              details: widget.json['details'] as Map<String, dynamic>,
              onChanged: (details) {
                // details를 json에 반영
                widget.onChanged({...widget.json, 'details': details});
              },
            ),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Row DueDateSector(BuildContext context) {
    Future<void> pickDatetime(BuildContext context) async {
      FocusScope.of(context).unfocus();
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate:
            _dueDateController.text.isNotEmpty
                ? DateTime.tryParse(_dueDateController.text) ?? DateTime.now()
                : DateTime.now(),
        firstDate: DateTime(DateTime.now().day),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        _dueDateController.text = picked.toIso8601String().split('T')[0];
        _notifyParent();
      }
    }

    return Row(
      children: [
        OutlinedButton.icon(
          icon: Icon(Icons.calendar_today, size: 14),
          label: Text(
            _dueDateController.text.isEmpty
                ? 'Due Date'
                : _dueDateController.text,
            style: TextStyle(fontSize: 12),
          ),
          onPressed: () async {
            await pickDatetime(context);
          },
        ),
      ],
    );
  }
}

class DetailSection extends StatefulWidget {
  final Map<String, dynamic>? details;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  const DetailSection({this.details, this.onChanged, super.key});

  @override
  State<DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<DetailSection> {
  late TextEditingController _locationController;
  late TextEditingController _timeController;
  late TextEditingController _memoController;
  late TextEditingController _subjectController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final details = widget.details ?? {};
    _locationController = TextEditingController(
      text: details['location'] ?? '',
    );
    _timeController = TextEditingController(text: details['time'] ?? '');
    _memoController = TextEditingController(text: details['memo'] ?? '');
    _subjectController = TextEditingController(text: details['subject'] ?? '');
    _categoryController = TextEditingController(
      text: details['category'] ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _timeController.dispose();
    _memoController.dispose();
    _subjectController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onChanged?.call({
      'location': _locationController.text,
      'time': _timeController.text,
      'memo': _memoController.text,
      'subject': _subjectController.text,
      'category': _categoryController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoState = Provider.of<TodoState>(listen: false, context);
    return Column(
      children: [
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: '장소'),
          onChanged: (_) => _notifyParent(),
        ),
        TextField(
          controller: _timeController,
          decoration: const InputDecoration(labelText: '시간'),
          onChanged: (_) => _notifyParent(),
        ),
        TextField(
          controller: _memoController,
          decoration: const InputDecoration(labelText: '메모'),
          onChanged: (_) => _notifyParent(),
        ),
        SubjectAndCategorySector(todoState),
      ],
    );
  }

  Row SubjectAndCategorySector(TodoState todoState) {
    return Row(
      children: [
        SubjectForm(todoState),

        Expanded(
          child: FutureBuilder(
            builder: (context, snapshot) {
              final subjectList = snapshot.data ?? [];
              return DropdownButtonFormField(
                items:
                    subjectList
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _categoryController.text = val ?? '';
                    _notifyParent();
                  });
                },
              );
            },
            future: todoState.fetchCategories(),
          ),
        ),
      ],
    );
  }

  Expanded SubjectForm(TodoState todoState) {
    return Expanded(
      child: FutureBuilder<List<String>>(
        future: todoState.fetchSubjects(),
        builder: (context, snapshot) {
          final subjectList = snapshot.data ?? [];
          final items = [
            ...subjectList.map(
              (subject) =>
                  DropdownMenuItem(value: subject, child: Text(subject)),
            ),
            const DropdownMenuItem(
              value: '__add_new__',
              child: Text('+ 새 과목 추가', style: TextStyle(color: Colors.blue)),
            ),
          ];
          return DropdownButtonFormField<String>(
            value:
                subjectList.contains(_subjectController.text)
                    ? _subjectController.text
                    : null,
            items: items,
            onChanged: (val) async {
              if (val == '__add_new__') {
                // 새 과목 입력 다이얼로그 띄우기
                final newSubject = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String temp = '';
                    return AlertDialog(
                      title: Text('새 과목 추가'),
                      content: TextField(
                        autofocus: true,
                        onChanged: (v) => temp = v,
                        decoration: InputDecoration(hintText: '과목명 입력'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, temp),
                          child: Text('추가'),
                        ),
                      ],
                    );
                  },
                );
                if (newSubject != null && newSubject.trim().isNotEmpty) {
                  await todoState.addSubject(newSubject.trim());
                  setState(() {
                    _subjectController.text = newSubject.trim();
                    _notifyParent();
                  });
                }
              } else {
                setState(() {
                  _subjectController.text = val ?? '';
                  _notifyParent();
                });
              }
            },
            decoration: const InputDecoration(labelText: '과목'),
          );
        },
      ),
    );
  }
}

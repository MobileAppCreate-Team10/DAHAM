import 'package:awesome_dialog/awesome_dialog.dart';
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
    body: SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: _TodoDialogContent(
          json: json ?? {},
          onChanged: (value) {
            result = value;
          },
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
          // 과목 선택
          SafeArea(
            child: Row(
              children: [
                Expanded(child: SubjectSelect(context)),
                SizedBox(width: 12),
                Expanded(child: CategorySelect(context)),
              ],
            ),
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
          // 세부사항(메모, 시간 등)은 아래에
          Visibility(
            child: DetailSection(
              details: _details,
              onChanged: (details) {
                setState(() {
                  _details = details;
                  _notifyParent();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget SubjectSelect(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Provider.of<TodoState>(listen: false, context).fetchSubjects(),
      builder: (context, snapshot) {
        final subjectList = snapshot.data ?? [];
        final items = [
          ...subjectList.map(
            (subject) => DropdownMenuItem(value: subject, child: Text(subject)),
          ),
          const DropdownMenuItem(
            value: '__add_new__',
            child: Text('+ 새 과목 추가', style: TextStyle(color: Colors.blue)),
          ),
        ];
        return DropdownButtonFormField<String>(
          value:
              subjectList.contains(_details['subject'])
                  ? _details['subject']
                  : null,
          items: items,
          onChanged: (val) async {
            if (val == '__add_new__') {
              // 새 과목 추가 다이얼로그
              final newSubject = await showDialog<String>(
                context: context,
                builder: (context) {
                  String temp = '';
                  return AlertDialog(
                    title: Text('새 과목 추가'),
                    content: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300), // 최대 너비 제한
                        child: TextField(
                          autofocus: true,
                          maxLines: 1,
                          onChanged: (v) => temp = v,
                          decoration: InputDecoration(hintText: '과목명 입력'),
                        ),
                      ),
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
                await Provider.of<TodoState>(
                  listen: false,
                  context,
                ).addSubject(newSubject.trim());
                setState(() {
                  _details['subject'] = newSubject.trim();
                  _notifyParent();
                });
              }
            } else {
              setState(() {
                _details['subject'] = val ?? '';
                _notifyParent();
              });
            }
          },
          decoration: const InputDecoration(labelText: '과목'),
        );
      },
    );
  }

  Widget CategorySelect(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Provider.of<TodoState>(listen: false, context).fetchCategories(),
      builder: (context, snapshot) {
        final categoryList = snapshot.data ?? [];
        final items = [
          ...categoryList.map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category)),
          ),
          const DropdownMenuItem(
            value: '__add_new__',
            child: Text('+ 새 카테고리 추가', style: TextStyle(color: Colors.blue)),
          ),
        ];
        return DropdownButtonFormField<String>(
          value:
              categoryList.contains(_details['category'])
                  ? _details['category']
                  : null,
          items: items,
          onChanged: (val) async {
            if (val == '__add_new__') {
              // 새 카테고리 입력 다이얼로그 띄우기
              final newCategory = await showDialog<String>(
                context: context,
                builder: (context) {
                  String temp = '';
                  return AlertDialog(
                    title: Text('새 카테고리 추가'),
                    content: SingleChildScrollView(
                      child: TextField(
                        autofocus: true,
                        maxLines: 1,
                        onChanged: (v) => temp = v,
                        decoration: InputDecoration(hintText: '카테고리명 입력'),
                      ),
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
              if (newCategory != null && newCategory.trim().isNotEmpty) {
                await Provider.of<TodoState>(
                  listen: false,
                  context,
                ).addCategory(newCategory.trim());
                setState(() {
                  _details['category'] = newCategory.trim();
                  _notifyParent();
                });
              }
            } else {
              setState(() {
                _details['category'] = val ?? '';
                _notifyParent();
              });
            }
          },
          isDense: true,
          decoration: const InputDecoration(labelText: '카테고리'),
        );
      },
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
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final details = widget.details ?? {};
    _controllers = {};
    for (final entry in details.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    final result = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      result[entry.key] = entry.value.text;
    }
    widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._controllers.entries.map(
          (entry) => Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: entry.key),
                  onChanged: (_) => _notifyParent(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _controllers.remove(entry.key)?.dispose();
                    _notifyParent();
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: OutlinedButton.icon(
            icon: Icon(Icons.add),
            label: Text('필드 추가'),
            onPressed: () async {
              final newKey = await showDialog<String>(
                context: context,
                builder: (context) {
                  String temp = '';
                  return AlertDialog(
                    title: Text('새 필드명 입력'),
                    content: TextField(
                      autofocus: true,
                      onChanged: (v) => temp = v,
                      decoration: InputDecoration(hintText: '예: 장소, 메모 등'),
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
              if (newKey != null &&
                  newKey.trim().isNotEmpty &&
                  !_controllers.containsKey(newKey)) {
                setState(() {
                  _controllers[newKey] = TextEditingController();
                  _notifyParent();
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

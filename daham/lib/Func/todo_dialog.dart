import 'package:daham/Provider/export.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

void todoDialog({required BuildContext context, Map<String, dynamic>? json}) {
  showDialog(
    context: context,
    builder: (_) {
      if (json == null) {
        return const Dialog(
          child: Padding(padding: EdgeInsets.all(24), child: Text('데이터가 없습니다')),
        );
      }
      return Dialog(
        child: Stack(
          children: [
            _TodoDialogContent(json: json),
            // 오른쪽 상단 닫기 버튼
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _TodoDialogContent extends StatefulWidget {
  final Map<String, dynamic> json;
  const _TodoDialogContent({required this.json});

  @override
  State<_TodoDialogContent> createState() => _TodoDialogContentState();
}

class _TodoDialogContentState extends State<_TodoDialogContent> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final json = widget.json;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '할 일: ${json['task'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          if (json['due_date'] != null)
            Row(
              children: [
                const Icon(Icons.calendar_today),
                SizedBox(width: 12),
                Text('${json['due_date']}'),
              ],
            ),
          SizedBox(height: 20),
          if (json['priority'] != null) Text('우선순위: ${json['priority']}'),
          SizedBox(height: 20),
          if (json['details'] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  icon: Icon(
                    size: 5,
                    _showDetails ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(_showDetails ? '닫기' : '상세 보기'),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState:
                      _showDetails
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (json['details'] as Map<String, dynamic>).entries
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text('${e.key}: ${e.value}'),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => _EditTodoDialog(json: json),
                  );
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  Provider.of<TodoState>(
                    listen: false,
                    context,
                  ).addTodoinUser(context, json);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.done_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditTodoDialog extends StatefulWidget {
  final Map<String, dynamic> json;
  const _EditTodoDialog({required this.json});

  @override
  State<_EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<_EditTodoDialog> {
  late TextEditingController _taskController;
  late TextEditingController _dueDateController;
  late TextEditingController _priorityController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.json['task'] ?? '');
    _dueDateController = TextEditingController(
      text: widget.json['due_date'] ?? '',
    );
    _priorityController = TextEditingController(
      text: widget.json['priority'] ?? '',
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _dueDateController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: '할 일'),
            ),
            TextField(
              controller: _dueDateController,
              decoration: const InputDecoration(labelText: '마감일'),
            ),
            TextField(
              controller: _priorityController,
              decoration: const InputDecoration(labelText: '우선순위'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // 수정된 값 저장 (여기서는 단순히 닫기만)
                    Navigator.of(context).pop();
                  },
                  child: const Text('저장'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

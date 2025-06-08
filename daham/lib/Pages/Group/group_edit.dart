import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Data/group.dart';

class GroupEditModal extends StatefulWidget {
  final Group group;
  const GroupEditModal({super.key, required this.group});

  @override
  State<GroupEditModal> createState() => _GroupEditModalState();
}

class _GroupEditModalState extends State<GroupEditModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.group.title);
    _descController = TextEditingController(text: widget.group.description);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('그룹 정보 수정', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '그룹 이름'),
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: '설명'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.group.id)
                  .update({
                    'title': _titleController.text,
                    'description': _descController.text,
                  });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('수정 완료'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Provider/group_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});
  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPublic = true;
  String? _inviteCode;
  File? _imageFile;
  int _minMembers = 2;
  int _maxMembers = 4;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  // 이미지 업로드
  Future<String?> _uploadImage(File file, String groupId) async {
    final ref = FirebaseStorage.instance.ref('group_images/$groupId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // 랜덤 초대코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 만들기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '그룹 이름'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: '그룹 설명'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('공개 여부:'),
                const SizedBox(width: 10),
                DropdownButton<bool>(
                  value: _isPublic,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('공개')),
                    DropdownMenuItem(value: false, child: Text('비공개(초대코드)')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _isPublic = v!;
                      if (!_isPublic) {
                        _inviteCode = _generateInviteCode();
                      } else {
                        _inviteCode = null;
                      }
                    });
                  },
                ),
                if (!_isPublic && _inviteCode != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('초대코드: $_inviteCode'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('최대 인원:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: '$_minMembers~$_maxMembers',
                  items: [
                    DropdownMenuItem(value: '2~4', child: Text('2~4명')),
                    DropdownMenuItem(value: '4~6', child: Text('4~6명')),
                    DropdownMenuItem(value: '6~8', child: Text('6~8명')),
                    DropdownMenuItem(value: '8~99', child: Text('8명 이상')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      if (v == '2~4') {
                        _minMembers = 2;
                        _maxMembers = 4;
                      } else if (v == '4~6') {
                        _minMembers = 4;
                        _maxMembers = 6;
                      } else if (v == '6~8') {
                        _minMembers = 6;
                        _maxMembers = 8;
                      } else {
                        _minMembers = 8;
                        _maxMembers = 99;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('그룹 이미지 선택'),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Image.file(_imageFile!, width: 60, height: 60),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final groupId = const Uuid().v4();
                String? imageUrl;
                if (_imageFile != null) {
                  imageUrl = await _uploadImage(_imageFile!, groupId);
                }
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                if (currentUserId == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
                  return;
                }
                // 그룹 객체 생성
                final newGroup = Group(
                  id: groupId,
                  title: _titleController.text,
                  description: _descController.text,
                  minMembers: _minMembers,
                  maxMembers: _maxMembers,
                  members: [currentUserId],
                  isPublic: _isPublic,
                  isPrivate: !_isPublic,
                  inviteCode: _inviteCode,
                  imageUrl: imageUrl,
                  ownerId: currentUserId,
                  memberInfo: {
                    currentUserId: {
                      'name': FirebaseAuth.instance.currentUser?.displayName ?? '사용자',
                      'email': FirebaseAuth.instance.currentUser?.email ?? '',
                      'uid': currentUserId,
                    }
                  },
                );

                // Firestore 저장
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .set(newGroup.toMap());

                Provider.of<GroupProvider>(
                  context,
                  listen: false,
                ).createGroup(newGroup);

                Navigator.pop(context);
              },
              child: const Text('생성'),
            ),
          ],
        ),
      ),
    );
  }
}

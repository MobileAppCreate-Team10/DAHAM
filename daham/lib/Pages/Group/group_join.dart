import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daham/Provider/group_provider.dart';
import 'package:daham/Data/group.dart';
import 'group_detail.dart';

class GroupJoinPage extends StatefulWidget {
  const GroupJoinPage({super.key});

  @override
  State<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends State<GroupJoinPage> {
  final _searchController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  Group? _foundGroup;
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('그룹 참가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: '그룹 이름 검색',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                final result = groupProvider.searchGroupByName(value);
                setState(() {
                  _foundGroup = result;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inviteCodeController,
              decoration: const InputDecoration(
                labelText: '초대코드로 참가',
                suffixIcon: Icon(Icons.vpn_key),
              ),
              onSubmitted: (code) async {
                final query =
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .where('inviteCode', isEqualTo: code)
                        .get();
                if (query.docs.isNotEmpty) {
                  final group = Group.fromMap(query.docs.first.data());
                  setState(() {
                    _foundGroup = group;
                  });
                } else {
                  setState(() {
                    _foundGroup = null;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            if (_foundGroup != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _foundGroup!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_foundGroup!.description),
                      const SizedBox(height: 8),
                      Text(
                        '참여 인원: ${_foundGroup!.members.length} / ${_foundGroup!.maxMembers}',
                      ),
                      const SizedBox(height: 16),
                      _foundGroup!.members.contains(_currentUserId)
                          ? const Text(
                            '✅ 이미 속한 그룹입니다',
                            style: TextStyle(color: Colors.grey),
                          )
                          : ElevatedButton(
                            onPressed:
                                _currentUserId == null
                                    ? null
                                    : () {
                                      groupProvider.joinGroup(
                                        _foundGroup!.id,
                                        _currentUserId!,
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => GroupDetailPage(
                                                group: _foundGroup!,
                                              ),
                                        ),
                                      );
                                    },
                            child: const Text('그룹 가입하기'),
                          ),
                    ],
                  ),
                ),
              )
            else if (_searchController.text.isNotEmpty)
              const Text('❌ 해당 이름의 그룹을 찾을 수 없습니다'),
          ],
        ),
      ),
    );
  }
}

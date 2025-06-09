import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Data/user.dart';
import 'package:daham/Pages/Group/group_detail.dart';

enum SearchType { group, friend }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchType _searchType = SearchType.group;
  final _searchController = TextEditingController();
  final _codeController = TextEditingController();
  List<Group> _groupResults = [];
  List<UserData> _userResults = [];
  Group? _privateGroupResult;
  bool _showCodeInput = false;
  bool _isLoading = false;

  // 그룹 검색
  Future<void> _searchPublicGroups(String query) async {
    setState(() {
      _isLoading = true;
      _groupResults = [];
    });
    final snapshot =
        await FirebaseFirestore.instance
            .collection('groups')
            .where('isPublic', isEqualTo: true)
            .get();
    final groups =
        snapshot.docs
            .map((doc) => Group.fromMap(doc.data()))
            .where((g) => g.title.contains(query))
            .toList();
    setState(() {
      _groupResults = groups;
      _isLoading = false;
    });
  }

  // 비공개 그룹 코드 검색
  Future<void> _searchPrivateGroupByCode(String code) async {
    setState(() {
      _isLoading = true;
      _privateGroupResult = null;
    });
    final query =
        await FirebaseFirestore.instance
            .collection('groups')
            .where('inviteCode', isEqualTo: code)
            .where('isPrivate', isEqualTo: true)
            .get();
    if (query.docs.isNotEmpty) {
      setState(() {
        _privateGroupResult = Group.fromMap(query.docs.first.data());
        _isLoading = false;
      });
    } else {
      setState(() {
        _privateGroupResult = null;
        _isLoading = false;
      });
    }
  }

  // 친구 추가 함수 (필드명 일치)
  Future<void> addFriend(String myUid, String friendUid) async {
    final users = FirebaseFirestore.instance.collection('users');
    await users.doc(myUid).update({
      'followingCount': FieldValue.increment(1),
      'friendIds': FieldValue.arrayUnion([friendUid]),
    });
    await users.doc(friendUid).update({
      'followerCount': FieldValue.increment(1),
    });
  }

  // 친구(유저) 검색
  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
      _userResults = [];
    });
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('userName', isGreaterThanOrEqualTo: query)
            .where('userName', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
    final users =
        snapshot.docs.map((doc) => UserData.fromMap(doc.data())).toList();
    setState(() {
      _userResults = users;
      _isLoading = false;
    });
  }

  // 전체 유저 일부만 미리 보여주기
  Future<void> _fetchSomeUsers() async {
    setState(() {
      _isLoading = true;
      _userResults = [];
    });
    final snapshot =
        await FirebaseFirestore.instance.collection('users').limit(10).get();
    final users =
        snapshot.docs.map((doc) => UserData.fromMap(doc.data())).toList();
    setState(() {
      _userResults = users;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (_searchType == SearchType.friend) {
      _fetchSomeUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 드롭다운으로 검색 타입 선택
            Row(
              children: [
                const Text('검색 종류: '),
                DropdownButton<SearchType>(
                  value: _searchType,
                  items: const [
                    DropdownMenuItem(
                      value: SearchType.group,
                      child: Text('그룹 검색'),
                    ),
                    DropdownMenuItem(
                      value: SearchType.friend,
                      child: Text('친구 검색'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _searchType = v!;
                      _searchController.clear();
                      _groupResults.clear();
                      _userResults.clear();
                      _privateGroupResult = null;
                      _showCodeInput = false;
                      if (_searchType == SearchType.friend) {
                        _fetchSomeUsers();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 3),
            if (_searchType == SearchType.group) ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: '공개 그룹 이름 검색',
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: _searchPublicGroups,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showCodeInput = !_showCodeInput;
                        _privateGroupResult = null;
                      });
                    },
                    child: const Text('코드 입력하기'),
                  ),
                ],
              ),
              if (_showCodeInput)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: '비공개 그룹 코드 입력',
                        suffixIcon: Icon(Icons.vpn_key),
                      ),
                      onSubmitted: _searchPrivateGroupByCode,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed:
                          () => _searchPrivateGroupByCode(_codeController.text),
                      child: const Text('검색'),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // 전체 그룹 목록
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '전체 그룹 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('groups')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final groups =
                        snapshot.data!.docs
                            .map(
                              (doc) => Group.fromMap(
                                doc.data() as Map<String, dynamic>,
                              ),
                            )
                            .toList();
                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return ListTile(
                          leading:
                              group.imageUrl != null &&
                                      group.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      group.imageUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const CircleAvatar(
                                    child: Icon(Icons.group),
                                  ),
                          title: Text(group.title),
                          subtitle: Text('${group.members.length}명 참여 중'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailPage(group: group),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              if (_privateGroupResult != null)
                Card(
                  color: Colors.yellow[100],
                  child: ListTile(
                    title: Text(_privateGroupResult!.title),
                    subtitle: Text(_privateGroupResult!.description),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  GroupDetailPage(group: _privateGroupResult!),
                        ),
                      );
                    },
                  ),
                ),
              if (!_isLoading &&
                  _searchController.text.isNotEmpty &&
                  _groupResults.isEmpty)
                const Text('❌ 해당 이름의 공개 그룹이 없습니다'),
              if (!_isLoading &&
                  _showCodeInput &&
                  _codeController.text.isNotEmpty &&
                  _privateGroupResult == null)
                const Text('❌ 해당 코드의 비공개 그룹이 없습니다'),
            ] else ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: '유저 이름 검색',
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: _searchUsers,
              ),
              const SizedBox(height: 16),
              if (_isLoading) const CircularProgressIndicator(),
              Expanded(
                child: ListView.builder(
                  itemCount: _userResults.length,
                  itemBuilder: (context, idx) {
                    final user = _userResults[idx];
                    return Card(
                      child: ListTile(
                        title: Text(user.userName),
                        subtitle: Text(user.description ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            // 친구 추가
                            final myUid =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (myUid == null || myUid == user.uid) return;
                            await addFriend(myUid, user.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${user.userName}님을 친구로 추가했습니다!'),
                              ),
                            );
                          },
                          child: const Text('친구 추가'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

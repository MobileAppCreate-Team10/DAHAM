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
  List<Group> _groupResults = [];
  List<UserData> _userResults = [];
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

  // 친구 추가 함수
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        backgroundColor: Colors.indigo[50],
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 드롭다운으로 검색 타입 선택
            Row(
              children: [
                const Text(
                  '검색 종류: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<SearchType>(
                  value: _searchType,
                  borderRadius: BorderRadius.circular(12),
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
                      if (_searchType == SearchType.friend) {
                        _fetchSomeUsers();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_searchType == SearchType.group) ...[
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '그룹 이름 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: _searchPublicGroups,
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '전체 그룹 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
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
                    if (groups.isEmpty) {
                      return const Center(child: Text('등록된 그룹이 없습니다.'));
                    }
                    return ListView.separated(
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
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
                                    : CircleAvatar(
                                      backgroundColor: Colors.indigo[100],
                                      child: const Icon(
                                        Icons.group,
                                        color: Colors.indigo,
                                      ),
                                    ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    group.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (group.isPrivate)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.lock,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          '비공개',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.public,
                                          size: 16,
                                          color: Colors.indigo,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          '공개',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('${group.members.length}명 참여 중'),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.indigo,
                            ),
                            onTap: () async {
                              if (group.isPrivate && group.inviteCode != null) {
                                final code = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    final _codeInputController =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: const Text('초대코드 입력'),
                                      content: TextField(
                                        controller: _codeInputController,
                                        decoration: const InputDecoration(
                                          labelText: '초대코드',
                                          suffixIcon: Icon(Icons.vpn_key),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('취소'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigo,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.pop(
                                                context,
                                                _codeInputController.text,
                                              ),
                                          child: const Text('입장'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (code != null && code == group.inviteCode) {
                                  final myUid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (myUid != null &&
                                      !group.members.contains(myUid)) {
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(group.id)
                                        .update({
                                          'members': FieldValue.arrayUnion([
                                            myUid,
                                          ]),
                                        });
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => GroupDetailPage(group: group),
                                    ),
                                  );
                                } else if (code != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('초대코드가 일치하지 않습니다.'),
                                    ),
                                  );
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => GroupDetailPage(group: group),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (!_isLoading &&
                  _searchController.text.isNotEmpty &&
                  _groupResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    '❌ 해당 이름의 공개 그룹이 없습니다',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ] else ...[
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '유저 이름 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: _searchUsers,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: _userResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final user = _userResults[idx];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo[100],
                          child: Text(
                            user.userName.isNotEmpty ? user.userName[0] : '?',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          user.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
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
              if (!_isLoading &&
                  _searchController.text.isNotEmpty &&
                  _userResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    '❌ 해당 이름의 유저가 없습니다',
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/user.dart';
import 'friend_detail.dart';

class MyFriendsPage extends StatelessWidget {
  const MyFriendsPage({super.key});

  Future<List<UserData>> _fetchFriends() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final friendIds = List<String>.from(userDoc.data()?['friendIds'] ?? []);
    if (friendIds.isEmpty) return [];
    final friendsQuery =
        await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: friendIds)
            .get();
    return friendsQuery.docs
        .map((doc) => UserData.fromMap(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // 친구 리스트
        Expanded(
          child: FutureBuilder<List<UserData>>(
            future: _fetchFriends(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final friends = snapshot.data ?? [];
              if (friends.isEmpty) {
                return const Center(child: Text('추가한 친구가 없습니다.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: friends.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final user = friends[idx];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.userName.isNotEmpty ? user.userName[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      subtitle:
                          user.description != null &&
                                  user.description!.isNotEmpty
                              ? Text(
                                user.description!,
                                style: theme.textTheme.bodyMedium,
                              )
                              : const Text('소개가 없습니다.'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.blueGrey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendDetailPage(user: user),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

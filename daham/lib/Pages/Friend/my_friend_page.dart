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
    return FutureBuilder<List<UserData>>(
      future: _fetchFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final friends = snapshot.data ?? [];
        if (friends.isEmpty) {
          return const Center(child: Text('추가한 친구가 없습니다.'));
        }
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, idx) {
            final user = friends[idx];
            return Card(
              child: ListTile(
                title: Text(user.userName),
                subtitle: Text(user.description ?? ''),
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
    );
  }
}

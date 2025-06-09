import 'package:flutter/material.dart';
import 'package:daham/Data/user.dart';

class FriendDetailPage extends StatelessWidget {
  final UserData user;
  const FriendDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user.userName}님의 정보')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이름: ${user.userName}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            if (user.description != null) Text('소개: ${user.description!}'),
            if (user.age != null) Text('나이: ${user.age}'),
            if (user.interest != null && user.interest!.isNotEmpty)
              Text('관심사: ${user.interest!.join(", ")}'),
            const SizedBox(height: 12),
            Text('팔로워: ${user.followerCount}'),
            Text('팔로잉: ${user.followingCount}'),
          ],
        ),
      ),
    );
  }
}

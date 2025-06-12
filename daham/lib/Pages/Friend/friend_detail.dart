import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/user.dart';
import 'package:fluttermoji/fluttermoji.dart';

class FriendDetailPage extends StatelessWidget {
  final UserData user;
  const FriendDetailPage({super.key, required this.user});

  Future<String?> _fetchAvatarJson() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return doc.data()?['avatarJson'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.userName}님의 프로필'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
      ),
      body: FutureBuilder<String?>(
        future: _fetchAvatarJson(),
        builder: (context, snapshot) {
          final avatarJson = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.blue[50],
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child:
                            avatarJson != null && avatarJson.isNotEmpty
                                ? FluttermojiCircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Colors.grey,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.userName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      if (user.description != null &&
                          user.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.blueGrey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cake, color: Colors.pink),
                              const SizedBox(width: 8),
                              Text(
                                user.age != null ? '${user.age}세' : '나이 정보 없음',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.interests, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child:
                                    user.interest != null &&
                                            user.interest!.isNotEmpty
                                        ? Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children:
                                              user.interest!
                                                  .map(
                                                    (i) => Chip(
                                                      label: Text(i),
                                                      backgroundColor:
                                                          Colors.green[50],
                                                    ),
                                                  )
                                                  .toList(),
                                        )
                                        : Text(
                                          '관심사 정보 없음',
                                          style: theme.textTheme.bodyLarge,
                                        ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.people, color: Colors.blue),
                                  const SizedBox(height: 4),
                                  Text(
                                    '팔로워',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  Text(
                                    '${user.followerCount}',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: Colors.grey[300],
                              ),
                              Column(
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '팔로잉',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  Text(
                                    '${user.followingCount}',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

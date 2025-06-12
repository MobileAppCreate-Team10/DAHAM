import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Pages/Group/group_detail.dart';

class MyGroupsPage extends StatelessWidget {
  const MyGroupsPage({super.key});

  Future<Map<String, String?>> fetchUserAvatars(List<String> userIds) async {
    final avatars = <String, String?>{};
    for (final uid in userIds) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      avatars[uid] = doc.data()?['avatarUrl']; // 혹은 avatarJson
    }
    return avatars;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(child: Text('로그인이 필요합니다.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups =
            snapshot.data!.docs
                .map((doc) => Group.fromMap(doc.data() as Map<String, dynamic>))
                .where((group) => group.members.contains(currentUserId))
                .toList();

        if (groups.isEmpty) {
          return const Center(child: Text('가입한 그룹이 없습니다.'));
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];

            return FutureBuilder<Map<String, String?>>(
              future: fetchUserAvatars(group.members.take(3).toList()),
              builder: (context, snapshot) {
                final avatars = snapshot.data ?? {};

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailPage(group: group),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                group.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.send, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('현재 ${group.members.length}명 참여중'),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: group.progress,
                            backgroundColor: Colors.grey[300],
                            color: Colors.green,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '진행률 ${(group.progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.green),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ...avatars.entries.map((entry) {
                                final url = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage:
                                        url != null ? NetworkImage(url) : null,
                                    child:
                                        url == null
                                            ? const Icon(Icons.person, size: 16)
                                            : null,
                                  ),
                                );
                              }),
                              if (group.members.length > 3)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  child: Text(
                                    '+${group.members.length - 3}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

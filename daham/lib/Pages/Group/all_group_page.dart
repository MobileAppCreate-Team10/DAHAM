import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:daham/Data/group.dart';
import 'package:daham/Pages/Group/group_detail.dart';

class AllGroupsPage extends StatelessWidget {
  const AllGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups =
            snapshot.data!.docs
                .map((doc) => Group.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

        if (groups.isEmpty) {
          return const Center(child: Text('생성된 그룹이 없습니다.'));
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              leading:
                  group.imageUrl != null && group.imageUrl!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          group.imageUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                      : const CircleAvatar(child: Icon(Icons.group)),
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
    );
  }
}

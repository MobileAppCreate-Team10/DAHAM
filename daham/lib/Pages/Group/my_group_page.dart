import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daham/Provider/group_provider.dart';
import 'package:daham/Pages/Group/group_detail.dart';

class MyGroupsPage extends StatelessWidget {
  const MyGroupsPage({super.key});

  final String _currentUserId = 'myUserId'; // 실제 로그인된 사용자 ID로 대체 필요

  @override
  Widget build(BuildContext context) {
    final groups =
        Provider.of<GroupProvider>(context).groups
            .where((group) => group.members.contains(_currentUserId))
            .toList();

    if (groups.isEmpty) {
      return const Center(child: Text('가입한 그룹이 없습니다.'));
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
              MaterialPageRoute(builder: (_) => GroupDetailPage(group: group)),
            );
          },
        );
      },
    );
  }
}

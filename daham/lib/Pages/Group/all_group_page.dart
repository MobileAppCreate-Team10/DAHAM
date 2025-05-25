import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daham/Provider/group_provider.dart';
import 'package:daham/Pages/Group/group_detail.dart';

class AllGroupsPage extends StatelessWidget {
  const AllGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = Provider.of<GroupProvider>(context).groups;

    if (groups.isEmpty) {
      return const Center(child: Text('생성된 그룹이 없습니다.'));
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return ListTile(
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

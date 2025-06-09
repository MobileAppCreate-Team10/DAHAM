import 'package:flutter/material.dart';
import 'group_create.dart';
import 'all_group_page.dart';
import 'my_group_page.dart';

class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 48),
          const TabBar(tabs: [Tab(text: '전체 그룹'), Tab(text: '나의 그룹')]),
          const Expanded(child: GroupHome()),
        ],
      ),
    );
  }
}

class GroupFAB extends StatelessWidget {
  const GroupFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder:
              (_) => ListTile(
                title: const Text('그룹 만들기'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupCreatePage()),
                  );
                },
              ),
        );
      },
    );
  }
}

class GroupHome extends StatelessWidget {
  const GroupHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(children: [AllGroupsPage(), MyGroupsPage()]);
  }
}

import 'package:flutter/material.dart';
import 'group_create.dart';
import 'group_join.dart';
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
          // AppBar 대신 직접 TabBar만 배치
          const SizedBox(height: 48), // AppBar 높이만큼 여백(필요시)
          const TabBar(tabs: [Tab(text: '전체 그룹'), Tab(text: '나의 그룹')]),
          Expanded(child: GroupHome()),
        ],
      ),
    );
  }
}

class GroupFAB extends StatelessWidget {
  const GroupFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (innerContext) => FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: innerContext,
                builder:
                    (_) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('그룹 만들기'),
                          onTap: () {
                            Navigator.pop(innerContext);
                            Navigator.push(
                              innerContext,
                              MaterialPageRoute(
                                builder: (_) => const GroupCreatePage(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          title: const Text('그룹 검색'),
                          onTap: () {
                            Navigator.pop(innerContext);
                            Navigator.push(
                              innerContext,
                              MaterialPageRoute(
                                builder: (_) => const GroupJoinPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
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

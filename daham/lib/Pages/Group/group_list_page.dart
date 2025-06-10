import 'package:flutter/material.dart';
import 'group_create.dart';
import 'my_group_page.dart';
import '../Friend/my_friend_page.dart';

class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 48),
            const TabBar(tabs: [Tab(text: '나의 그룹'), Tab(text: '나의 친구')]),
            const Expanded(
              child: TabBarView(children: [MyGroupsPage(), MyFriendsPage()]),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            // 나의 그룹 탭(0)일 때만 FAB 노출
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, _) {
                if (tabController.index == 0) {
                  return FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupCreatePage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}

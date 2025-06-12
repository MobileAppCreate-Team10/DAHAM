import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Pages/Login/log_out_dialog.dart';
import 'package:daham/Pages/User/weekly.dart';
import 'package:daham/Provider/export.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:provider/provider.dart';
import 'package:daham/Data/calendar_page.dart'; // ← 이 경로로 바뀜

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, _) {
        return Column(
          children: [
            ProfileSector(userData: userState.userData),
            Expanded(child: FeedSector(userUid: userState.userData['uid'])),
          ],
        );
      },
    );
  }
}

class ProfileSector extends StatelessWidget {
  final dynamic userData;

  const ProfileSector({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FluttermojiCircleAvatar(radius: 55),
                SizedBox(height: 12),
                Text('${userData['userName']}'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FollowSector(userData: userData),
                userData['bio'] == ''
                    ? Text('아직 소개글이 없습니다')
                    : Text(userData['bio']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FollowSector extends StatelessWidget {
  const FollowSector({super.key, required this.userData});

  final dynamic userData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {},
          child: Column(
            children: [Text('Follower'), Text('${userData['followerCount']}')],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Text('Following'),
              Text('${userData['followingCount']}'),
            ],
          ),
        ),
      ],
    );
  }
}

class FeedSector extends StatefulWidget {
  final String userUid;
  const FeedSector({super.key, required this.userUid});

  @override
  State<FeedSector> createState() => _FeedSectorState();
}

class _FeedSectorState extends State<FeedSector> {
  late Future<Map<DateTime, int>> _completedFuture;

  @override
  void initState() {
    super.initState();
    _completedFuture = fetchCompletedPerDay(widget.userUid);
  }

  Future<Map<DateTime, int>> fetchCompletedPerDay(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('UserTodo')
        .doc(uid)
        .collection('todos')
        .where('complete', isEqualTo: true)
        .get();

    Map<DateTime, int> result = {};

    for (var doc in snapshot.docs) {
      final details = doc['details'];
      if (details != null && details['time'] != null) {
        try {
          final date = DateTime.parse(details['time']);
          result[date] = (result[date] ?? 0) + 1;
        } catch (e) {
          print('날짜 파싱 오류: ${details['time']}');
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Weekly Do'),
              Tab(text: '달력'), // ← 여기에 달력 들어감
            ],
            labelColor: Colors.black,
          ),
          Expanded(
            child: TabBarView(
              children: [
                Consumer<TodoState>(
                  builder: (context, todos, _) {
                    final weekMap = todos.fetchThisWeekTodosByWeekday();
                    // 월(1)~일(7) 순서로 각 요일별 할 일 개수 리스트 생성
                    final totalTodos = [
                      for (var i = 1; i <= 7; i++) weekMap[i]?.length ?? 0,
                    ];
                    // 완료 개수도 필요하다면 비슷하게 리스트 생성
                    final completedTodos = [
                      for (var i = 1; i <= 7; i++)
                        weekMap[i]?.where((item) => item.complete).length ?? 0,
                    ];
                    return WeeklyChart(
                      totalTodos: totalTodos,
                      completedTodos: completedTodos,
                    );
                  },
                ),
                Center(child: CalendarPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('My Page'),
      actions: [
        Builder(
          builder: (context) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profileSetting');
                  },
                ),
                IconButton(
                  onPressed: () => showSignOutDialog(context),
                  icon: Icon(Icons.logout),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MyPageDrawer extends StatelessWidget {
  const MyPageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('설정')),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('프로필 설정'),
            onTap: () {
              Navigator.pushNamed(context, '/profileSetting');
            },
          ),
        ],
      ),
    );
  }
}
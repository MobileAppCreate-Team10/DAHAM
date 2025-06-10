import 'package:daham/Pages/Login/log_out_dialog.dart';
import 'package:daham/Provider/appstate.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:provider/provider.dart';
import 'package:daham/Data/calendar_page.dart';  // ← 이 경로로 바뀜
import 'package:daham/Data/chart_page.dart';


class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, _) {
        return Column(
          children: [
            ProfileSector(userData: userState.userData),
            Expanded(child: FeedSector()), // FeedSector만 Expanded로!
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
      height: 180, // 높이 지정
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
  const FeedSector({super.key});

  @override
  State<FeedSector> createState() => _FeedSectorState();
}

class _FeedSectorState extends State<FeedSector> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Activity'),
              Tab(text: '달력',),  // ← 여기에 달력 들어감
              Tab(text: 'Badges'),
            ],
            labelColor: Colors.black, // 필요시 색상 지정
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
      padding: const EdgeInsets.all(12.0),
      child: ChartPage( // ← 클래스 이름!
  completedPerDay: {
    DateTime.now().subtract(Duration(days: 6)): 2,
    DateTime.now().subtract(Duration(days: 5)): 1,
    DateTime.now().subtract(Duration(days: 4)): 3,
    DateTime.now().subtract(Duration(days: 3)): 0,
    DateTime.now().subtract(Duration(days: 2)): 4,
    DateTime.now().subtract(Duration(days: 1)): 1,
    DateTime.now(): 5,
  },
),
    ),
    CalendarPage(),
    Center(child: Text('test3')),
                Center(child: CalendarPage()),
                Center(child: Text('test3')),
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
                    // Scaffold.of(context).openEndDrawer();
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

import 'package:daham/Data/user.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:provider/provider.dart';

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
    return Container(
      width: double.infinity,
      height: 300, // 높이 지정
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    FluttermojiCircleAvatar(radius: 55),
                    Positioned(
                      child: IconButton(
                        onPressed: () {
                          print('Hello');
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('${userData['userName']}'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [FollowSector(userData: userData), Text('3')],
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
        Column(
          children: [Text('Follower'), Text('${userData['followerCount']}')],
        ),
        Column(
          children: [Text('Following'), Text('${userData['followingCount']}')],
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
              Tab(text: '피드2'),
              Tab(text: 'Badges'),
            ],
            labelColor: Colors.black, // 필요시 색상 지정
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('test1')),
                Center(child: Text('test2')),
                Center(child: Text('test3')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

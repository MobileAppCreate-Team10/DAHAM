import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileSector(),
        Expanded(child: FeedSector()), // FeedSector만 Expanded로!
      ],
    );
  }
}

class ProfileSector extends StatelessWidget {
  const ProfileSector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300, // 높이 지정
      decoration: BoxDecoration(color: Colors.red),
      child: Row(
        children: [
          Container(width: 120, color: Colors.blue),
          Expanded(
            child: Container(decoration: BoxDecoration(color: Colors.yellow)),
          ),
        ],
      ),
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

import 'package:daham/Data/task.dart';

class Group {
  final String id;
  final String title;
  final String description;
  final int minMembers;
  final int maxMembers;
  final List<String> members;
  final bool isPublic;
  final bool isPrivate;
  final String? inviteCode;
  final String? imageUrl;
  double progress;
  final List<Task> tasks;
  final String ownerId;
  final Map<String, dynamic> memberInfo; // ✅ 추가

  Group({
    required this.id,
    required this.title,
    required this.description,
    required this.minMembers,
    required this.maxMembers,
    required this.members,
    required this.isPublic,
    required this.isPrivate,
    required this.ownerId,
    required this.memberInfo,
    this.inviteCode,
    this.imageUrl,
    this.progress = 0.0,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'minMembers': minMembers,
    'maxMembers': maxMembers,
    'members': members,
    'isPublic': isPublic,
    'isPrivate': isPrivate,
    'inviteCode': inviteCode,
    'imageUrl': imageUrl,
    'progress': progress,
    'ownerId': ownerId,
    'tasks': tasks.map((task) => task.toMap()).toList(),
      'memberInfo': memberInfo, // ✅ 여기!
  };

  factory Group.fromMap(Map<String, dynamic> map) => Group(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    minMembers: map['minMembers'],
    maxMembers: map['maxMembers'],
    members: List<String>.from(map['members']),
    isPublic: map['isPublic'],
    isPrivate: map['isPrivate'] ?? false,
    inviteCode: map['inviteCode'],
    imageUrl: map['imageUrl'],
    progress: map['progress'] ?? 0.0,
    ownerId: map['ownerId'],
    memberInfo: Map<String, dynamic>.from(map['memberInfo'] ?? {}), // ✅ 여기!
    tasks:
        (map['tasks'] as List<dynamic>? ?? [])
            .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
  );
}

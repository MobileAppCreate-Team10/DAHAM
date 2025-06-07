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
  late final double progress;
  final List<Task> tasks;

  Group({
    required this.id,
    required this.title,
    required this.description,
    required this.minMembers,
    required this.maxMembers,
    required this.members,
    required this.isPublic,
    required this.isPrivate,
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
    'inviteCode': inviteCode,
    'imageUrl': imageUrl,
    'progress': progress,
    // tasks는 Firestore에 맞게 변환 필요
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
    // tasks는 Firestore에서 변환 필요
  );
}

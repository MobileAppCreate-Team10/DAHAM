class UserData {
  final String uid;
  final String userName;
  String? description;
  int? age;
  List<String>? interest;
  int followerCount;
  int followingCount;
  List<String> friendIds;

  UserData({
    required this.uid,
    required this.userName,
    this.age,
    this.description,
    this.interest,
    this.followerCount = 0,
    this.followingCount = 0,
    List<String>? friendIds,
  }) : friendIds = friendIds ?? [];

  // firestore에 저장할 때 사용
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'userName': userName,
    'description': description,
    'age': age,
    'interest': interest,
    'followerCount': followerCount,
    'followingCount': followingCount,
    'friendIds': friendIds,
  };

  factory UserData.fromMap(Map<String, dynamic> map) => UserData(
    uid: map['uid']?.toString() ?? '',
    userName: map['userName']?.toString() ?? '',
    description: map['description']?.toString(),
    age: map['age'] is int ? map['age'] : null,
    interest:
        map['interest'] != null ? List<String>.from(map['interest']) : null,
    followerCount: map['followerCount'] ?? 0,
    followingCount: map['followingCount'] ?? 0,
    friendIds:
        map['friendIds'] != null ? List<String>.from(map['friendIds']) : [],
  );
}

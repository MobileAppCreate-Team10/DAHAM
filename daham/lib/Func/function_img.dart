import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

Future<String?> uploadImageToStorage(
  File imageFile,
  String groupId,
  String userId,
) async {
  try {
    final storageRef = FirebaseStorage.instance.ref().child(
      'planeIMG/$groupId/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('이미지 업로드 실패: $e');
    return null;
  }
}

// 예시: 그룹 상세 페이지의 build 또는 원하는 위치에 추가
Widget buildReceiverImage(String groupId, String receiverId) {
  return StreamBuilder<QuerySnapshot>(
    stream:
        FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('images')
            .where('receiver', isEqualTo: receiverId)
            .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();
      final docs = snapshot.data!.docs;
      if (docs.isEmpty) return const SizedBox();

      return ExpansionTile(
        title: Text('비행기 착륙 (${docs.length}대)'),
        children:
            docs.map((doc) {
              final imgUrl = doc['url'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imgUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
      );
    },
  );
}

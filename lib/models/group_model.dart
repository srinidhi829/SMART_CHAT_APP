import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String groupName;
  final String adminId;
  final String groupImage;
  final List<dynamic> members;
  final Timestamp createdAt;

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.adminId,
    required this.groupImage,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "groupId": groupId,
      "groupName": groupName,
      "adminId": adminId,
      "groupImage": groupImage,
      "members": members,
      "createdAt": createdAt,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map["groupId"] ?? "",
      groupName: map["groupName"] ?? "",
      adminId: map["adminId"] ?? "",
      groupImage: map["groupImage"] ?? "",
      members: map["members"] ?? [],
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}
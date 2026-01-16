class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }
}
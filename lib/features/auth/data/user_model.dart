import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String role; // 'user' | 'admin'
  final int credits; // remaining generations this week
  final DateTime? creditsResetAt; // when credits were last topped up
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.role = 'user',
    this.credits = 0,
    this.creditsResetAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get hasCredits => credits > 0;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: d['email'] as String?,
      displayName: d['displayName'] as String?,
      role: (d['role'] as String?) ?? 'user',
      credits: (d['credits'] as int?) ?? 0,
      creditsResetAt: (d['creditsResetAt'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'role': role,
        'credits': credits,
        if (creditsResetAt != null)
          'creditsResetAt': Timestamp.fromDate(creditsResetAt!),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UserModel copyWith({
    String? email,
    String? displayName,
    String? role,
    int? credits,
    DateTime? creditsResetAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        uid: uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        credits: credits ?? this.credits,
        creditsResetAt: creditsResetAt ?? this.creditsResetAt,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

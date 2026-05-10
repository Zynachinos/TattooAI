import 'package:cloud_firestore/cloud_firestore.dart';

class EntitlementModel {
  final String uid;
  final bool isPro;
  final String? productId; // e.g. 'weekly'
  final String? periodType; // 'normal' | 'trial' | 'intro'
  final DateTime? expiresAt;
  final DateTime? updatedAt;

  const EntitlementModel({
    required this.uid,
    this.isPro = false,
    this.productId,
    this.periodType,
    this.expiresAt,
    this.updatedAt,
  });

  bool get isActive {
    if (!isPro) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  factory EntitlementModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EntitlementModel(
      uid: doc.id,
      isPro: (d['isPro'] as bool?) ?? false,
      productId: d['productId'] as String?,
      periodType: d['periodType'] as String?,
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'isPro': isPro,
        'productId': productId,
        'periodType': periodType,
        if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum GenerationStatus { queued, generating, completed, failed }

extension GenerationStatusX on GenerationStatus {
  String get value => name;

  static GenerationStatus from(String? raw) => switch (raw) {
        'queued' => GenerationStatus.queued,
        'generating' => GenerationStatus.generating,
        'completed' => GenerationStatus.completed,
        'failed' => GenerationStatus.failed,
        _ => GenerationStatus.queued,
      };
}

class GenerationRequestModel {
  final String id;
  final String uid;
  final GenerationStatus status;
  final String? prompt;
  final String baseImagePath; // Storage: users/{uid}/generation_requests/{id}/base.jpg
  final String? referenceImagePath; // Storage: .../reference.jpg
  final String? resultImagePath; // Storage: .../result.jpg
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt; // 24h TTL

  const GenerationRequestModel({
    required this.id,
    required this.uid,
    this.status = GenerationStatus.queued,
    this.prompt,
    required this.baseImagePath,
    this.referenceImagePath,
    this.resultImagePath,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  bool get isTerminal =>
      status == GenerationStatus.completed || status == GenerationStatus.failed;

  bool get isInProgress =>
      status == GenerationStatus.queued ||
      status == GenerationStatus.generating;

  factory GenerationRequestModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GenerationRequestModel(
      id: doc.id,
      uid: d['uid'] as String,
      status: GenerationStatusX.from(d['status'] as String?),
      prompt: d['prompt'] as String?,
      baseImagePath: d['baseImagePath'] as String,
      referenceImagePath: d['referenceImagePath'] as String?,
      resultImagePath: d['resultImagePath'] as String?,
      errorMessage: d['errorMessage'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'status': status.value,
        if (prompt != null) 'prompt': prompt,
        'baseImagePath': baseImagePath,
        if (referenceImagePath != null) 'referenceImagePath': referenceImagePath,
        if (resultImagePath != null) 'resultImagePath': resultImagePath,
        if (errorMessage != null) 'errorMessage': errorMessage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      };

  GenerationRequestModel copyWith({
    GenerationStatus? status,
    String? resultImagePath,
    String? errorMessage,
  }) =>
      GenerationRequestModel(
        id: id,
        uid: uid,
        status: status ?? this.status,
        prompt: prompt,
        baseImagePath: baseImagePath,
        referenceImagePath: referenceImagePath,
        resultImagePath: resultImagePath ?? this.resultImagePath,
        errorMessage: errorMessage ?? this.errorMessage,
        createdAt: createdAt,
        updatedAt: updatedAt,
        expiresAt: expiresAt,
      );
}

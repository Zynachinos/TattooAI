import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../auth/auth_service.dart';
import '../../core/utils/firestore_paths.dart';
import 'data/generation_request_model.dart';
import 'data/image_upload_service.dart';

class GenerationState {
  final GenerationStatus? status;
  final String? requestId;
  final String? resultImagePath;
  final String? error;
  final double uploadProgress; // 0.0 – 1.0
  final bool isUploading;

  const GenerationState({
    this.status,
    this.requestId,
    this.resultImagePath,
    this.error,
    this.uploadProgress = 0,
    this.isUploading = false,
  });

  bool get isIdle => status == null;
  bool get isActive =>
      isUploading ||
      status == GenerationStatus.queued ||
      status == GenerationStatus.generating;
  bool get isCompleted => status == GenerationStatus.completed;
  bool get isFailed => status == GenerationStatus.failed;

  GenerationState copyWith({
    GenerationStatus? status,
    String? requestId,
    String? resultImagePath,
    String? error,
    double? uploadProgress,
    bool? isUploading,
  }) =>
      GenerationState(
        status: status ?? this.status,
        requestId: requestId ?? this.requestId,
        resultImagePath: resultImagePath ?? this.resultImagePath,
        error: error ?? this.error,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        isUploading: isUploading ?? this.isUploading,
      );
}

class GenerationService extends ChangeNotifier {
  GenerationService._();
  static final GenerationService instance = GenerationService._();

  GenerationState _state = const GenerationState();
  GenerationState get state => _state;

  void _setState(GenerationState s) {
    _state = s;
    notifyListeners();
  }

  void reset() => _setState(const GenerationState());

  Future<void> generate({
    required File baseImage,
    File? referenceImage,
    String? prompt,
  }) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return;

    final requestId = const Uuid().v4();

    try {
      // ── 1. Upload base image ───────────────────────────────────────────────
      _setState(_state.copyWith(isUploading: true, uploadProgress: 0));

      await ImageUploadService.instance.uploadBaseImage(
        uid: uid,
        requestId: requestId,
        file: baseImage,
        onProgress: (p) =>
            _setState(_state.copyWith(uploadProgress: p * 0.6)),
      );

      // ── 2. Upload reference image (optional) ──────────────────────────────
      String? referenceImagePath;
      if (referenceImage != null) {
        final result = await ImageUploadService.instance.uploadReferenceImage(
          uid: uid,
          requestId: requestId,
          file: referenceImage,
          onProgress: (p) =>
              _setState(_state.copyWith(uploadProgress: 0.6 + p * 0.3)),
        );
        referenceImagePath = result.path;
      }

      _setState(_state.copyWith(
          isUploading: false, uploadProgress: 0.9, status: GenerationStatus.queued));

      // ── 3. Create Firestore document ──────────────────────────────────────
      final db = FirebaseFirestore.instance;
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      await db.doc(FirestorePaths.generationRequest(requestId)).set({
        'uid': uid,
        'status': 'queued',
        if (prompt != null && prompt.isNotEmpty) 'prompt': prompt,
        'baseImagePath':
            'users/$uid/generation_requests/$requestId/base.jpg',
        'referenceImagePath': referenceImagePath,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setState(_state.copyWith(
          requestId: requestId, uploadProgress: 1.0));

      // ── 4. Call Cloud Function ────────────────────────────────────────────
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west6')
          .httpsCallable('createGeneration');
      await fn.call({'requestId': requestId, 'prompt': prompt});

      // ── 5. Listen to Firestore status updates ─────────────────────────────
      _listenToRequest(requestId);
    } catch (e) {
      // rollback storage files on error
      await ImageUploadService.instance.deleteRequestFiles(uid, requestId);
      _setState(GenerationState(error: e.toString()));
    }
  }

  void _listenToRequest(String requestId) {
    FirebaseFirestore.instance
        .doc(FirestorePaths.generationRequest(requestId))
        .snapshots()
        .listen(
      (snap) {
        if (!snap.exists) return;
        final model = GenerationRequestModel.fromFirestore(snap);
        _setState(_state.copyWith(
          status: model.status,
          resultImagePath: model.resultImagePath,
          error: model.errorMessage,
        ));
      },
      onError: (e) => _setState(GenerationState(error: e.toString())),
    );
  }
}

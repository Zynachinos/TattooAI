import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/utils/storage_paths.dart';

class UploadResult {
  final String path;
  const UploadResult(this.path);
}

class ImageUploadService {
  ImageUploadService._();
  static final ImageUploadService instance = ImageUploadService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads [file] to the base image slot for [requestId].
  /// Returns the Storage path on success.
  Future<UploadResult> uploadBaseImage({
    required String uid,
    required String requestId,
    required File file,
    void Function(double progress)? onProgress,
  }) =>
      _upload(
        path: StoragePaths.baseImage(uid, requestId),
        file: file,
        onProgress: onProgress,
      );

  /// Uploads [file] to the reference image slot for [requestId].
  Future<UploadResult> uploadReferenceImage({
    required String uid,
    required String requestId,
    required File file,
    void Function(double progress)? onProgress,
  }) =>
      _upload(
        path: StoragePaths.referenceImage(uid, requestId),
        file: file,
        onProgress: onProgress,
      );

  Future<UploadResult> _upload({
    required String path,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref(path);
    final task = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    if (onProgress != null) {
      task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });
    }

    await task;
    return UploadResult(path);
  }

  /// Deletes all files for a request (used in cleanup / error rollback).
  Future<void> deleteRequestFiles(String uid, String requestId) async {
    final paths = [
      StoragePaths.baseImage(uid, requestId),
      StoragePaths.referenceImage(uid, requestId),
      StoragePaths.resultImage(uid, requestId),
    ];
    await Future.wait(
      paths.map((p) => _storage.ref(p).delete().catchError((_) {})),
    );
  }
}

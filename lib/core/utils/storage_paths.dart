class StoragePaths {
  StoragePaths._();

  static String _base(String uid, String requestId) =>
      'users/$uid/generation_requests/$requestId';

  static String baseImage(String uid, String requestId) =>
      '${_base(uid, requestId)}/base.jpg';

  static String referenceImage(String uid, String requestId) =>
      '${_base(uid, requestId)}/reference.jpg';

  static String resultImage(String uid, String requestId) =>
      '${_base(uid, requestId)}/result.jpg';
}

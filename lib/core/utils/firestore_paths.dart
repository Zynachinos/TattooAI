class FirestorePaths {
  FirestorePaths._();

  static String user(String uid) => 'users/$uid';
  static String entitlement(String uid) => 'entitlements/$uid';
  static String generationRequest(String requestId) =>
      'generation_requests/$requestId';

  static const String users = 'users';
  static const String entitlements = 'entitlements';
  static const String generationRequests = 'generation_requests';
}

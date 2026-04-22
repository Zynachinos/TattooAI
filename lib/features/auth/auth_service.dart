import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../billing/billing_service.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String _role = 'user';
  String? _error;

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _role == 'admin';
  String? get error => _error;

  void init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _user = user;
      _error = null;
      if (user != null) {
        await _loadRole(user.uid);
        await BillingService.instance.login(user.uid);
      } else {
        _role = 'user';
        await BillingService.instance.logout();
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _loadRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      _role = (doc.data()?['role'] as String?) ?? 'user';
    } catch (_) {
      _role = 'user';
    }
  }

  Future<void> _upsertUserDoc(User user) async {
    final ref =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'email': user.email,
        'displayName': user.displayName,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'email': user.email,
        'displayName': user.displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ─── Email / Password ───────────────────────────────────────────────────────

  Future<void> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _error = null;
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmailPassword(String email, String password) async {
    _setLoading(true);
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _upsertUserDoc(result.user!);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // ─── Google Login ────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await _upsertUserDoc(result.user!);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _setError(_mapError(e.code));
    } catch (_) {
      _setError('Google Login fehlgeschlagen.');
    } finally {
      _setLoading(false);
    }
  }

  // ─── Sign out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-Mail oder Passwort falsch.';
      case 'email-already-in-use':
        return 'Diese E-Mail ist bereits registriert.';
      case 'weak-password':
        return 'Passwort muss mindestens 6 Zeichen haben.';
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse.';
      case 'too-many-requests':
        return 'Zu viele Versuche. Bitte kurz warten.';
      default:
        return 'Fehler: $code';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../billing/billing_service.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _user = user;
      _error = null;
      if (user != null) {
        await BillingService.instance.login(user.uid);
      } else {
        await BillingService.instance.logout();
      }
      notifyListeners();
    });
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      if (googleUser == null) return; // User hat abgebrochen

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
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

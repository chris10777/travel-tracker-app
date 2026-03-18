import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─────────────────────────────────────────────
  // 🔄 AUTH STATE
  // ─────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────
  // 📧 EMAIL AUTH
  // ─────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // 🔁 PASSWORD RESET
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // ─────────────────────────────────────────────
  // 🔐 GOOGLE SIGN-IN
  // ─────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User hat abgebrochen
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  // ─────────────────────────────────────────────
  // 🚪 LOGOUT
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    // Google ggf. trennen
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}

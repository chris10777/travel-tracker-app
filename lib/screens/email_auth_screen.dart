import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EmailAuthScreen extends StatefulWidget {
  final VoidCallback onContinueAsGuest;

  const EmailAuthScreen({
    super.key,
    required this.onContinueAsGuest,
  });

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool isLogin = true;
  bool loading = false;

  final _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // EMAIL LOGIN / REGISTER
  // ─────────────────────────────────────────────
  Future<void> _submitEmail() async {
    setState(() => loading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      }
      // ❗ KEIN Navigator.pop → AuthGate übernimmt
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ─────────────────────────────────────────────
  // GOOGLE LOGIN
  // ─────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() => loading = true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Abgebrochen
        setState(() => loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception:', '').trim()),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(isLogin ? 'Login' : 'Register'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✉️ EMAIL
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔒 PASSWORD
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                const SizedBox(height: 24),

                // EMAIL LOGIN / REGISTER
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submitEmail,
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),
                ),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? 'Create account'
                        : 'Already have an account?',
                  ),
                ),

                const SizedBox(height: 16),

                const Divider(),

                const SizedBox(height: 16),

                // 🔐 GOOGLE LOGIN
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Continue with Google'),
                    onPressed: loading ? null : _signInWithGoogle,
                  ),
                ),

                const SizedBox(height: 12),

                // 👤 GUEST MODE
                TextButton(
                  onPressed: widget.onContinueAsGuest,
                  child: const Text(
                    'Continue without login',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ⏳ LOADING OVERLAY
        if (loading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

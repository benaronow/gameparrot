import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  String? _uid;
  bool _isLoading = false;
  String? _errorMessage;

  String? get uid => _uid;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(bool isLogin, String email, String password) async {
    try {
      final auth = FirebaseAuth.instance;
      if (isLogin) {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
        final idToken = await user.getIdToken();
        await http.post(
          Uri.parse('${Config.httpUrl}/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
    }
  }

  Future<UserCredential> googleLogin() async {
    if (kIsWeb) {
      // Web sign-in
      final GoogleAuthProvider authProvider = GoogleAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        authProvider,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
        final idToken = await user.getIdToken();
        await http.post(
          Uri.parse('${Config.httpUrl}/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );
        notifyListeners();
      }
      return userCredential;
    } else {
      // Mobile (iOS/Android) sign-in
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        clientId: kIsWeb ? dotenv.env['WEB_OAUTH_CLIENT'] : null,
      );
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.authenticate();
      } catch (e) {
        throw Exception("Google Sign-In aborted");
      }
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
        final idToken = await user.getIdToken();
        await http.post(
          Uri.parse('${Config.httpUrl}/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );
        notifyListeners();
      }
      return userCredential;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _uid = null;
    notifyListeners();
  }

  Future<void> authUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken();
      final authResponse = await http.post(
        Uri.parse('${Config.httpUrl}/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      if (!authResponse.body.contains("Invalid token")) {
        _uid = authResponse.body.split("Authenticated UID: ")[0];
        notifyListeners();
      }
    }
  }

  void resetErr() {
    _errorMessage = null;
    notifyListeners();
  }
}

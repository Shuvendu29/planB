import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _handleFirstLogin();
  }

  Future<void> registerWithEmail(String email, String password, String name) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user document
    UserModel user = UserModel(
      uid: userCredential.user!.uid,
      email: email,
      name: name,
      points: 5, // First login bonus
      firstLogin: true,
      role: 'user',
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    // Implement Google Sign-In (requires google_sign_in package)
    // For now, placeholder
    throw UnimplementedError('Google Sign-In not implemented yet');
  }

  Future<void> signInWithPhone(String phoneNumber, String smsCode) async {
    // Implement phone auth
    throw UnimplementedError('Phone auth not implemented yet');
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> _handleFirstLogin() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists) {
        // First login
        UserModel user = UserModel(
          uid: currentUser!.uid,
          email: currentUser!.email!,
          points: 5,
          firstLogin: true,
          role: 'user',
        );
        await _firestore.collection('users').doc(currentUser!.uid).set(user.toMap());
      }
    }
  }
}
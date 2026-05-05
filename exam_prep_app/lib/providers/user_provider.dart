import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> loadUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _user = UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      notifyListeners();
    }
  }

  Future<void> topUp(int rupees) async {
    if (_user == null) return;

    int pointsToAdd = rupees; // 1 Rs = 1 point
    bool isFirstTopup = !_user!.firstTopup;

    if (isFirstTopup) {
      pointsToAdd += (rupees * 0.05).toInt(); // 5% extra
    }

    // Update user points
    await _firestore.collection('users').doc(_user!.uid).update({
      'points': FieldValue.increment(pointsToAdd),
      'firstTopup': true,
    });

    // Record transaction
    await _firestore.collection('transactions').add({
      'userId': _user!.uid,
      'amount': rupees,
      'pointsAdded': pointsToAdd,
      'type': 'topup',
      'timestamp': Timestamp.now(),
    });

    // Reload user
    await loadUser(_user!.uid);
  }

  Future<void> spendPoints(int points) async {
    if (_user == null || _user!.points < points) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'points': FieldValue.increment(-points),
    });

    // Record transaction
    await _firestore.collection('transactions').add({
      'userId': _user!.uid,
      'amount': -points,
      'pointsAdded': -points,
      'type': 'spend',
      'timestamp': Timestamp.now(),
    });

    await loadUser(_user!.uid);
  }
}
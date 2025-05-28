import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal.dart';

class GoalController extends ChangeNotifier {
  final List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addGoal(Goal goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    goal.userId = user.uid;
    goal.createdAt = DateTime.now();

    try {
      final doc = await _firestore.collection('goals').add(goal.toMap());
      goal.id = doc.id;
      _goals.add(goal);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar a meta: $e');
    }
  }

  Future<void> fetchGoals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('goals')
          .where('userId', isEqualTo: user.uid)
          .get();

      _goals.clear();
      for (var doc in snapshot.docs) {
        _goals.add(Goal.fromMap(doc.id, doc.data()));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar metas: $e');
    }
  }

  void removeGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  double calculateProjection(Goal goal) {
    return goal.calculateProjection();
  }
}

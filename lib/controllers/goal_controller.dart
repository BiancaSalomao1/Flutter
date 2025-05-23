import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalController extends ChangeNotifier {
  final List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void removeGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  double calculateProjection(Goal goal) {
    return goal.calculateProjection();
  }
}

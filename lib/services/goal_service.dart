import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal.dart';

Stream<List<Goal>> streamGoalsByUser(String userId) {
  return FirebaseFirestore.instance
      .collection('goals')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Goal.fromMap(doc.id, doc.data())).toList());
}

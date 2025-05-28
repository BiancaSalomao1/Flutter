import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aporte.dart';

class AporteService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Aporte>> getAportesByGoal(String goalId) {
    return _db
        .collection('aportes')
        .where('goalId', isEqualTo: goalId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Aporte.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addAporte(Aporte aporte) async {
    await _db.collection('aportes').add(aporte.toMap());
  }
}

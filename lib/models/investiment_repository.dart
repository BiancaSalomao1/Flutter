import 'package:appeducafin/models/investment_suggestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appeducafin/services/api_service.dart';
final ApiService apiService = ApiService(); // Sem Dio

Future<List<InvestmentSuggestion>> fetchSuggestions() async {
  try {
    return await apiService.getSuggestions();
  } catch (e) {
    print("Erro ao buscar sugestões: $e");
    rethrow;
  }
}
Future<List<InvestmentSuggestion>> fetchSuggestionsFromFirestore() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('investments').get();
    return snapshot.docs.map((doc) => InvestmentSuggestion.fromJson(doc.data())).toList();
  } catch (e) {
    print("Erro ao buscar sugestões do Firestore: $e");
    rethrow;
  }
}

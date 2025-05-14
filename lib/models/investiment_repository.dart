import 'package:dio/dio.dart';
import 'package:appeducafin/services/api_service.dart';
import 'package:appeducafin/models/investment_suggestion.dart';

final Dio dio = Dio();
final ApiService apiService = ApiService(dio);

Future<List<InvestmentSuggestion>> fetchSuggestions() async {
  try {
    return await apiService.getSuggestions();
  } catch (e) {
    print("Erro ao buscar sugestões: $e");
    rethrow;
  }
}

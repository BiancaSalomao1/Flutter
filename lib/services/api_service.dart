import 'dart:convert';
import 'package:appeducafin/models/investment_suggestion.dart';
import 'package:http/http.dart' as http;
import 'package:appeducafin/services/twelve_data_service.dart'; 

class ApiService {
  final String _baseUrl = 'https://api.twelvedata.com';

  Future<Map<String, dynamic>?> fetchQuote(String symbol) async {
    final url = Uri.parse('$_baseUrl/quote?symbol=$symbol&apikey=$twelveDataApiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Erro na chamada: ${response.statusCode}');
      return null;
    }
  }

  Future<List<InvestmentSuggestion>> getSuggestions() async {
    final localSuggestions = [
      InvestmentSuggestion(
        title: 'CDB Multimercado',
        min: 1000.00,
        rate: 1.1,
        months: 12,
        tax: '15%',
        fee: '0%',
        symbol: 'BRL=X',
      ),
      InvestmentSuggestion(
        title: 'Ações Nubank (NU)',
        min: 500.00,
        rate: 1.4,
        months: 24,
        tax: '20%',
        fee: '0.5%',
        symbol: 'NU',
      ),
    ];

    for (var suggestion in localSuggestions) {
      if (suggestion.symbol != null && suggestion.symbol!.isNotEmpty) {
        final quote = await fetchQuote(suggestion.symbol!);
        if (quote != null && quote['close'] != null) {
          // Você pode usar quote['close'] se quiser atualizar algum campo aqui
        }
      }
    }

    return localSuggestions;
  }
}

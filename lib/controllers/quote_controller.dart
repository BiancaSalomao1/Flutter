import 'package:flutter/material.dart';
import '../services/twelve_data_service.dart';

class QuoteController extends ChangeNotifier {
  final TwelveDataService _service = TwelveDataService();

  Map<String, dynamic>? _quoteData;
  String? _lastSymbol;
  bool _isLoading = false;

  Map<String, dynamic>? get quoteData => _quoteData;
  String? get lastSymbol => _lastSymbol;
  bool get isLoading => _isLoading;

  Future<void> fetchQuote(String symbol) async {
    _isLoading = true;
    notifyListeners();

    try {
      _quoteData = await _service.fetchQuote(symbol);
      _lastSymbol = symbol;
    } catch (e) {
      print('Erro ao buscar cotação: $e');
      _quoteData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

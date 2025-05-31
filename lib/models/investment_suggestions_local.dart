import '../models/investment_suggestion.dart';

final List<InvestmentSuggestion> localSuggestions = [
  InvestmentSuggestion(
    title: 'Nubank Ações',
    min: 100.00,
    rate: 1.2,
    months: 12,
    tax: '15%',
    fee: '0%',
    symbol: 'NU',
  ),
 
  InvestmentSuggestion(
    title: 'Mercado Pago Ações',
    min: 50.00,
    rate: 0.8,
    months: 6,
    tax: '15%',
    fee: '0%',
    symbol: 'MP',
  ),
];

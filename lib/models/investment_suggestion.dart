import 'package:json_annotation/json_annotation.dart';

part 'investment_suggestion.g.dart';

@JsonSerializable()
class InvestmentSuggestion {
  final String title;
  final double min;
  final double rate;
  final int months;
  final String tax;
  final String fee;

  InvestmentSuggestion({
    required this.title,
    required this.min,
    required this.rate,
    required this.months,
    required this.tax,
    required this.fee,
  });

  factory InvestmentSuggestion.fromJson(Map<String, dynamic> json) =>
      _$InvestmentSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentSuggestionToJson(this);
}


// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvestmentSuggestion _$InvestmentSuggestionFromJson(
        Map<String, dynamic> json) =>
    InvestmentSuggestion(
      title: json['title'] as String,
      min: (json['min'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      months: (json['months'] as num).toInt(),
      tax: json['tax'] as String,
      fee: json['fee'] as String,
    );

Map<String, dynamic> _$InvestmentSuggestionToJson(
        InvestmentSuggestion instance) =>
    <String, dynamic>{
      'title': instance.title,
      'min': instance.min,
      'rate': instance.rate,
      'months': instance.months,
      'tax': instance.tax,
      'fee': instance.fee,
    };

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/investment_suggestion.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://localhost:8080/api/quote")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/suggestions")
  Future<List<InvestmentSuggestion>> getSuggestions();
}

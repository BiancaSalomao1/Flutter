import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:appeducafin/services/api_service.dart';
import 'package:appeducafin/models/investment_suggestion.dart';
import 'package:appeducafin/views/calculator.dart';

class InvestmentSuggestionsPage extends StatefulWidget {
  const InvestmentSuggestionsPage({super.key});

  @override
  State<InvestmentSuggestionsPage> createState() => _InvestmentSuggestionsPageState();
}

class _InvestmentSuggestionsPageState extends State<InvestmentSuggestionsPage> {
  late final ApiService apiService;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    apiService = ApiService(dio);
  }

  Future<List<InvestmentSuggestion>> fetchSuggestions() async {
    try {
      final result = await apiService.getSuggestions();
      print(" Recebido: ${result.length} sugestões");
      return result;
    } catch (e) {
      print(" Erro Retrofit: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<InvestmentSuggestion>>(
          future: fetchSuggestions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma sugestão encontrada.'));
            }

            final suggestions = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Sugestões de Investimentos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...suggestions.map((inv) => _buildCard(context, inv)).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, InvestmentSuggestion inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.purple),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  inv.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalculatorPage(
                        initialAmount: inv.min,
                        months: inv.months,
                        interestRate: inv.rate,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'RESUMO\n'
              'Aporte Mínimo: R\$ ${inv.min.toStringAsFixed(2)}\n'
              'Taxa de Juros: ${inv.rate.toStringAsFixed(2)}% a.m\n'
              'Tempo Mínimo: ${inv.months} meses\n'
              'Imposto de Renda: ${inv.tax}\n'
              'Taxa Bancária: ${inv.fee}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

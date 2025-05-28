import 'package:flutter/material.dart';
import '../models/investment_suggestion.dart';
import '../models/investment_suggestions_local.dart';
import '../services/api_service.dart';
import 'calculator.dart';

class InvestmentSuggestionsPage extends StatefulWidget {
  const InvestmentSuggestionsPage({super.key});

  @override
  State<InvestmentSuggestionsPage> createState() => _InvestmentSuggestionsPageState();
}

class _InvestmentSuggestionsPageState extends State<InvestmentSuggestionsPage> {
  final ApiService apiService = ApiService();
  final TextEditingController _symbolController = TextEditingController();
  Map<String, dynamic>? searchedQuote;
  String? searchedSymbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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

            // Sugestões locais
            ...localSuggestions.map((inv) => _buildCard(context, inv)).toList(),

            const Divider(),
            const SizedBox(height: 12),

            // Campo para pesquisar ativo manualmente
            const Text(
              'Buscar Ativo Manualmente:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Símbolo do ativo (ex: NU)',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final symbol = _symbolController.text.trim().toUpperCase();
                if (symbol.isEmpty) return;
                final quote = await apiService.fetchQuote(symbol);
                setState(() {
                  searchedQuote = quote;
                  searchedSymbol = symbol;
                });
              },
              child: const Text('Ver Cotação'),
            ),

            if (searchedQuote != null && searchedQuote!['close'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Cotação de $searchedSymbol: R\$ ${searchedQuote!['close']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Adicionar à Calculadora'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalculatorPage(
                        initialAmount: double.tryParse(searchedQuote!['close']) ?? 0,
                        months: 12,
                        interestRate: 1.0,
                      ),
                    ),
                  );
                },
              )
            ]
          ],
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
          const SizedBox(height: 8),
          if (inv.symbol != null && inv.symbol!.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                final data = await apiService.fetchQuote(inv.symbol!);
                if (data != null && data['close'] != null) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Cotação - ${inv.symbol}'),
                      content: Text('Valor atual: R\$ ${data['close']}'),
                      actions: [
                        TextButton(
                          child: const Text('Fechar'),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao buscar cotação')),
                  );
                }
              },
              child: Text('Ver cotação de ${inv.symbol}'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:appeducafin/views/calculator.dart'; // ajuste o import conforme seu projeto

class InvestmentSuggestionsPage extends StatelessWidget {
  const InvestmentSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = [
      {
        'title': 'CDB Banco C3 Multimercado',
        'min': 1000.0,
        'rate': 1.03,
        'months': 30,
        'tax': 'Sim',
        'fee': 'Isento'
      },
      {
        'title': 'Fundo CDI 105%',
        'min': 0.0,
        'rate': 1.01,
        'months': 0,
        'tax': 'Sim',
        'fee': 'Isento'
      },
      {
        'title': 'FII MFIIXX',
        'min': 100.0,
        'rate': 1.00,
        'months': 12,
        'tax': 'Não',
        'fee': '1% lucro'
      },
    ];

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
            ...suggestions.map((investment) => _buildCard(context, investment)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> inv) {
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
              Expanded(child: Text(inv['title'], style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalculatorPage(
                        initialAmount: inv['min'],
                        months: inv['months'],
                        interestRate: inv['rate'],
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
              'Aporte Mínimo: R\$ ${inv['min'].toStringAsFixed(2)}\n'
              'Taxa de Juros: ${inv['rate'].toStringAsFixed(2)}% a.m\n'
              'Tempo Mínimo: ${inv['months']} meses\n'
              'Incide Imposto de Renda: ${inv['tax']}\n'
              'Taxa de Manutenção bancária: ${inv['fee']}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

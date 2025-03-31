import 'package:flutter/material.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const GoalsContent(),
    );
  }
}

class GoalsContent extends StatelessWidget {
  const GoalsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildGoalGroup(
                    title: 'APOSENTADORIA',
                    color: Colors.orange,
                    suggestions: [
                      'CDB Banco C3\nMultimercado',
                      'Tesouro Direto\n2026',
                      'FII trimestral',
                    ],
                    resumo: const {
                      'Aportes': 'R\$ 108.830,00',
                      'Juros': 'R\$1.348,09',
                      'Tempo': '38 meses'
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGoalGroup(
                    title: 'CASA PRÓPRIA',
                    color: Colors.red,
                    suggestions: ['Fundo CDI 105%'],
                    resumo: const {
                      'Aportes': 'R\$ 12.000,00',
                      'Juros': 'R\$300,00',
                      'Tempo': '12 meses'
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Metas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Icon(Icons.add_circle_outline, size: 28),
      ],
    );
  }

  Widget _buildGoalGroup({
    required String title,
    required Color color,
    required List<String> suggestions,
    required Map<String, String> resumo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainGoal(title, color),
        const SizedBox(height: 8),
        ...suggestions.map(_buildSuggestionItem).toList(),
        const SizedBox(height: 8),
        _buildResumo(resumo),
      ],
    );
  }

  Widget _buildMainGoal(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.widgets, color: color),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.show_chart, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
          const Icon(Icons.remove_circle_outline),
        ],
      ),
    );
  }

  Widget _buildResumo(Map<String, String> resumo) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'RESUMO\n'
        'Aportes: ${resumo['Aportes']}\n'
        'Juros: ${resumo['Juros']}\n'
        'Tempo: ${resumo['Tempo']}',
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ControlExpensesPage extends StatelessWidget {
  const ControlExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Como Controlar suas Despesas')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dicas para controlar os gastos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Controlar as despesas é fundamental para manter a saúde financeira. Um bom controle evita dívidas, permite economias e facilita o alcance de metas.'),
              SizedBox(height: 20),
              Text('Sugestões práticas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Anote todos os seus gastos diariamente.'),
              Text('• Separe despesas fixas e variáveis.'),
              Text('• Estabeleça um limite mensal para cada categoria de gasto.'),
              Text('• Use aplicativos ou planilhas para acompanhar seus gastos.'),
            ],
          ),
        ),
      ),
    );
  }
}

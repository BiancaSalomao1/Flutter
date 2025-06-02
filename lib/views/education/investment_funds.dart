import 'package:flutter/material.dart';

class InvestmentFundsPage extends StatelessWidget {
  const InvestmentFundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fundos de Investimento')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('O que são Fundos de Investimento?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Fundos de investimento são uma forma coletiva de aplicação, em que diversos investidores aplicam seus recursos em um portfólio administrado por um gestor profissional.'),
              SizedBox(height: 20),
              Text('Vantagens dos Fundos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Diversificação automática de ativos.'),
              Text('• Gestão profissional dos recursos.'),
              Text('• Facilidade de acesso a ativos variados.'),
            ],
          ),
        ),
      ),
    );
  }
}

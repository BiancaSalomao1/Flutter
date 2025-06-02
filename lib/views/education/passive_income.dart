import 'package:flutter/material.dart';

class PassiveIncomePage extends StatelessWidget {
  const PassiveIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('O que é Renda Passiva')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Definição de Renda Passiva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Renda passiva é o dinheiro que você ganha regularmente com pouco ou nenhum esforço ativo. Ela pode vir de investimentos, como juros sobre aplicações financeiras, aluguel de imóveis ou participação em empresas.'),
              SizedBox(height: 20),
              Text('Exemplos comuns de renda passiva:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Juros de aplicações financeiras (Tesouro Direto, CDBs, etc).'),
              Text('• Aluguel de imóveis.'),
              Text('• Dividendos de ações.'),
            ],
          ),
        ),
      ),
    );
  }
}

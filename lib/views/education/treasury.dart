import 'package:flutter/material.dart';

class TreasuryPage extends StatelessWidget {
  const TreasuryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tesouro Direto')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('O que é Tesouro Direto?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('O Tesouro Direto é um programa do governo federal que permite a pessoas físicas investirem em títulos públicos pela internet. É uma das formas mais seguras de investimento no Brasil.'),
              SizedBox(height: 20),
              Text('Vantagens do Tesouro Direto:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Baixo risco, pois é garantido pelo governo.'),
              Text('• Acessível: investimentos a partir de valores baixos.'),
              Text('• Opções com rentabilidade prefixada, pós-fixada e IPCA.'),
            ],
          ),
        ),
      ),
    );
  }
}

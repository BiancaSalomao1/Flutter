import 'package:flutter/material.dart';

class TypesOfInvestmentsPage extends StatelessWidget {
  const TypesOfInvestmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipos de Investimentos')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Principais Tipos de Investimentos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Existem diversos tipos de investimentos, cada um com seus riscos, prazos e rentabilidades. Conhecer as opções ajuda a tomar melhores decisões para seu perfil.'),
              SizedBox(height: 20),
              Text('Investimentos comuns:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Renda fixa: Tesouro Direto, CDBs, LCIs e LCAs.'),
              Text('• Renda variável: ações, fundos imobiliários.'),
              Text('• Fundos de investimento: diversas carteiras geridas por especialistas.'),
              Text('• Previdência privada: voltada ao longo prazo e aposentadoria.'),
            ],
          ),
        ),
      ),
    );
  }
}

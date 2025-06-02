import 'package:flutter/material.dart';

class CDBsPage extends StatelessWidget {
  const CDBsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CDBs')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('O que são CDBs?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Os Certificados de Depósito Bancário (CDBs) são títulos emitidos por bancos para captar dinheiro. Em troca, os bancos pagam juros ao investidor após um prazo determinado.'),
              SizedBox(height: 20),
              Text('Características dos CDBs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Rentabilidade pode ser prefixada, pós-fixada ou híbrida.'),
              Text('• Garantido pelo FGC até R\$ 250 mil por CPF e instituição.'),
              Text('• Boa opção para objetivos de curto a médio prazo.'),
            ],
          ),
        ),
      ),
    );
  }
}

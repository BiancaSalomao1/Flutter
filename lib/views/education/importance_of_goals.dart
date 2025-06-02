import 'package:flutter/material.dart';

class ImportanceOfGoalsPage extends StatelessWidget {
  const ImportanceOfGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importância de Metas'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Por que definir metas financeiras?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Definir metas financeiras é essencial para manter o foco nos seus objetivos e evitar gastos desnecessários. '
                'Quando você estabelece uma meta, como comprar uma casa ou fazer uma viagem, fica mais fácil tomar decisões conscientes sobre seus hábitos de consumo.',
              ),
              SizedBox(height: 20),
              Text(
                'Benefícios das metas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Direcionam seus esforços para o que realmente importa.'),
              Text('• Ajudam a criar disciplina financeira.'),
              Text('• Tornam seus sonhos mais tangíveis e mensuráveis.'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              const Text(
                'Sobre Nós',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Este aplicativo foi desenvolvido com o objetivo de auxiliar os usuários na organização de metas financeiras, investimentos e educação financeira de forma prática e intuitiva.\n\n'
                'A missão é tornar o planejamento financeiro acessível a todos, promovendo autonomia e clareza nas decisões sobre o dinheiro.\n\n'
                'Se você tiver sugestões ou encontrar problemas, entre em contato! \n\n'
                'bialfsalomao35@gmail.com - Bianca Salomão\n\n'
                'Esta é uma versão preliminar do aplicativo para fins de teste e feedback. Agradecemos por sua compreensão e apoio.\n\n',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Sobre Nós',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class EducationalContentPage extends StatelessWidget {
  const EducationalContentPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(width: 8),
                const Text(
                  'Conteúdo Educacional',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCard(Icons.shield, 'Importância de Metas'),
            _buildCard(Icons.flash_on, 'O que é renda passiva'),
            _buildCard(Icons.school, 'Tipos de Investimentos'),
            _buildCard(Icons.edit, 'Como Controlar suas Despesas'),

            const SizedBox(height: 32),
            const Text(
              'Indicações de Investimento\nConservadores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildCard(Icons.shield, 'Tesouro Direto'),
            _buildCard(Icons.flash_on, 'CDBs'),
            _buildCard(Icons.school, 'Fundos'),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.pink.shade100,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:appeducafin/views/education/importance_of_goals.dart';
import 'package:appeducafin/views/education/passive_income.dart';
import 'package:appeducafin/views/education/types_of_investments.dart';
import 'package:appeducafin/views/education/control_expenses.dart';
import 'package:appeducafin/views/education/treasury.dart';
import 'package:appeducafin/views/education/cdbs.dart';
import 'package:appeducafin/views/education/investment_funds.dart';

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

            _buildCard(context, Icons.shield, 'Importância de Metas', const ImportanceOfGoalsPage()),
            _buildCard(context, Icons.flash_on, 'O que é renda passiva', const PassiveIncomePage()),
            _buildCard(context, Icons.school, 'Tipos de Investimentos', const TypesOfInvestmentsPage()),
            _buildCard(context, Icons.edit, 'Como Controlar suas Despesas', const ControlExpensesPage()),

            const SizedBox(height: 32),
            const Text(
              'Indicações de Investimento\nConservadores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildCard(context, Icons.shield, 'Tesouro Direto', const TreasuryPage()),
            _buildCard(context, Icons.flash_on, 'CDBs', const CDBsPage()),
            _buildCard(context, Icons.school, 'Fundos', const InvestmentFundsPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
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
      ),
    );
  }
}
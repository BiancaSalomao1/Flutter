import 'package:flutter/material.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final List<GoalAlert> goals = [
    GoalAlert(
      title: 'CDB Banco C3 Multimercado',
      monthDeposit: 800,
      appliedMonths: 12,
      depositedMonths: 10,
      pendingMonths: 2,
      estimatedAmount: 2000000,
      passiveIncome: 2000,
      remainingTime: '3 anos e 4 meses',
      totalInvestment: 12000,
      totalInterest: 300,
    ),
    // Adicione mais metas aqui se quiser
  ];

  void _checkDeposit(GoalAlert goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Depósito Confirmado'),
        content: Text('Você marcou o depósito do mês como realizado para "${goal.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _extraDeposit(GoalAlert goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Depósito extra realizado em "${goal.title}".'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _editGoal(GoalAlert goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Metas e Prazos'),
        content: const Text('Aqui você poderá editar as metas no futuro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return _buildGoalCard(goal);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      const SizedBox(width: 4),
      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
      const SizedBox(width: 8),
      const Text(
        'Alertas Metas e Prazos',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  );
}


  Widget _buildGoalCard(GoalAlert goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalTitle(goal.title),
          const SizedBox(height: 12),
          Text('Aporte do Mês: R\$ ${goal.monthDeposit.toStringAsFixed(2)}'),
          Text('Tempo: aplicado ${goal.appliedMonths} meses'),
          const SizedBox(height: 8),
          Text('Meses Depositados com Sucesso: ${goal.depositedMonths}'),
          Text('Meses pendentes: ${goal.pendingMonths}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _checkDeposit(goal),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Check Depósito Mensal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _extraDeposit(goal),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Depósito Extra'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('CONFIGURAÇÕES',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Montante estimado: R\$${goal.estimatedAmount.toStringAsFixed(2)}'),
          Text('Renda passiva estimada: R\$${goal.passiveIncome.toStringAsFixed(2)}'),
          Text('Tempo restante: ${goal.remainingTime}'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _editGoal(goal),
              child: const Text('EDITAR METAS E PRAZOS'),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'RESUMO\n'
              'Aportes: R\$${goal.totalInvestment.toStringAsFixed(2)}\n'
              'Juros: R\$${goal.totalInterest.toStringAsFixed(2)}\n'
              'Tempo: ${goal.appliedMonths} meses',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.show_chart, color: Colors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Icon(Icons.check_circle_outline),
      ],
    );
  }
}

class GoalAlert {
  final String title;
  final double monthDeposit;
  final int appliedMonths;
  final int depositedMonths;
  final int pendingMonths;
  final double estimatedAmount;
  final double passiveIncome;
  final String remainingTime;
  final double totalInvestment;
  final double totalInterest;

  GoalAlert({
    required this.title,
    required this.monthDeposit,
    required this.appliedMonths,
    required this.depositedMonths,
    required this.pendingMonths,
    required this.estimatedAmount,
    required this.passiveIncome,
    required this.remainingTime,
    required this.totalInvestment,
    required this.totalInterest,
  });
}

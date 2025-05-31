import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  List<GoalAlert> _goalAlerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGoalAlerts();
  }

  Future<void> _loadGoalAlerts() async {
    final goalsSnapshot = await FirebaseFirestore.instance.collection('goals').get();
    final historySnapshot = await FirebaseFirestore.instance.collection('history').get();

    final now = DateTime.now();
    List<GoalAlert> alerts = [];

    for (var doc in goalsSnapshot.docs) {
      final goalId = doc.id;
      final data = doc.data();
      final String title = data['category'] ?? 'Meta';
      final double monthly = (data['monthly'] as num).toDouble();
      final int totalMonths = (data['months'] as num).toInt();
      final double rate = (data['rate'] as num).toDouble();
      final double finalAmount = (data['finalAmount'] as num).toDouble();

      final historyDoc = historySnapshot.docs.firstWhere(
        (h) => h.id == goalId,
        orElse: () => throw Exception('Histórico não encontrado para $goalId'),
      );

      final List<dynamic> itemsRaw = historyDoc['items'] ?? [];
      final confirmed = itemsRaw.where((e) => e['confirmed'] == true).toList();
      final pending = itemsRaw.where((e) => e['confirmed'] != true).toList();

      final confirmedMonths = confirmed.length;
      final pendingMonths = pending.length;
      final totalInvested = confirmed.fold(0.0, (sum, e) => sum + (e['amount'] as num));
      final estimatedInterest = finalAmount - (monthly * totalMonths);
      final passiveIncome = (totalInvested * rate) - totalInvested;
      final lastDepositDate = confirmed.isNotEmpty
          ? (confirmed.last['timestamp'] as Timestamp).toDate()
          : null;

      final Duration sinceLast = lastDepositDate != null ? now.difference(lastDepositDate) : Duration.zero;
      final String tempoRestante = '${(totalMonths - confirmedMonths) ~/ 12} anos e ${(totalMonths - confirmedMonths) % 12} meses';

      alerts.add(GoalAlert(
        title: title,
        monthDeposit: monthly,
        appliedMonths: totalMonths,
        depositedMonths: confirmedMonths,
        pendingMonths: pendingMonths,
        estimatedAmount: finalAmount,
        passiveIncome: passiveIncome,
        remainingTime: tempoRestante,
        totalInvestment: totalInvested,
        totalInterest: estimatedInterest,
      ));

      // Aqui você pode disparar o alerta para a Home se sinceLast > 30 dias
    }

    setState(() {
      _goalAlerts = alerts;
      _loading = false;
    });
  }

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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _goalAlerts.length,
                        itemBuilder: (context, index) {
                          final goal = _goalAlerts[index];
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

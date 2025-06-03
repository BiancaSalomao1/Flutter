import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alert.dart';

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
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      print('DEBUG: UserId = $userId');
      
      if (userId == null) {
        print('DEBUG: User not authenticated');
        setState(() {
          _loading = false;
        });
        return;
      }

      print('DEBUG: Fetching goals...');
      final goalsSnapshot =
          await FirebaseFirestore.instance
              .collection('goals')
              .where('userId', isEqualTo: userId)
              .where('deleted', isEqualTo: false)
              .get();

      print('DEBUG: Found ${goalsSnapshot.docs.length} goals');

      print('DEBUG: Fetching history...');
      final historySnapshot =
          await FirebaseFirestore.instance
              .collection('history')
              .get();

      print('DEBUG: Found ${historySnapshot.docs.length} history documents');

      final now = DateTime.now();
      List<GoalAlert> alerts = [];

      for (var doc in goalsSnapshot.docs) {
        final goalId = doc.id;
        final data = doc.data();
        
        print('DEBUG: Processing goal $goalId with data: $data');

        final String title = data['category'] ?? data['title'] ?? data['name'] ?? 'Meta';
        final double monthly = (data['monthly'] ?? data['monthlyAmount'] ?? 0).toDouble();
        final int totalMonths = (data['months'] ?? data['totalMonths'] ?? 0).toInt();
        final double rate = (data['rate'] ?? data['interestRate'] ?? 1.0).toDouble();
        final double finalAmount = (data['finalAmount'] ?? data['targetAmount'] ?? 0).toDouble();

        // Pular metas dummy/placeholder
        if (data['isDummy'] == true || monthly == 0 || totalMonths == 0) {
          print('DEBUG: Skipping dummy/placeholder goal: $goalId');
          continue;
        }

        print('DEBUG: Goal parsed - title: $title, monthly: $monthly, months: $totalMonths');

        final historyDoc = historySnapshot.docs.firstWhereOrNull(
          (h) => h.id == goalId,
        );

        print('DEBUG: History doc for $goalId: ${historyDoc != null ? "found" : "not found"}');

        // FIX: Extract items from history document
        final List<dynamic> itemsRaw = historyDoc?.data()?['items'] ?? [];
        final List<Map<String, dynamic>> items = itemsRaw.cast<Map<String, dynamic>>();

        print('DEBUG: Processing ${items.length} items');

        final confirmed = items.where((e) => e['confirmed'] == true).toList();
        final pending = items.where((e) => e['confirmed'] != true).toList();

        final confirmedMonths = confirmed.length;
        final pendingMonths = pending.length;
        final totalInvested = confirmed.fold<double>(
          0.0,
          (sum, e) => sum + ((e['amount'] ?? 0) as num).toDouble(),
        );

        print('DEBUG: Confirmed months: $confirmedMonths, Pending months: $pendingMonths, Total invested: $totalInvested');

        final estimatedInterest = finalAmount - (monthly * totalMonths);
        final passiveIncome = (totalInvested * (rate / 100));

        final lastDepositDate =
            confirmed.isNotEmpty
                ? (confirmed.last['timestamp'] as Timestamp?)?.toDate()
                : null;

        final Duration sinceLast =
            lastDepositDate != null
                ? now.difference(lastDepositDate)
                : Duration.zero;
                
        if (sinceLast.inDays >= 30) {
          await _salvarAtraso(goalId, title, lastDepositDate ?? now);
        }

        final String tempoRestante =
            '${(totalMonths - confirmedMonths) ~/ 12} anos e ${(totalMonths - confirmedMonths) % 12} meses';

        print('DEBUG: Creating alert for $title');
        
        alerts.add(
          GoalAlert(
            goalId: goalId,
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
          ),
        );
      }

      print('DEBUG: Created ${alerts.length} alerts');

      setState(() {
        _goalAlerts = alerts;
        _loading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading goal alerts: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _checkDeposit(GoalAlert goal) async {
    // Confirma o aporte no Firestore
    await _confirmarAporte(goal.goalId);
    
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Depósito Confirmado'),
            content: Text(
              'Você marcou o depósito do mês como realizado para "${goal.title}".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _extraDeposit(GoalAlert goal) async {
    // Solicita o valor do depósito extra
    final TextEditingController controller = TextEditingController();
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Depósito Extra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Adicionar depósito extra para "${goal.title}"'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      await _adicionarDepositoExtra(goal.goalId, result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Depósito extra de R\$${result.toStringAsFixed(2)} realizado em "${goal.title}".'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _editGoal(GoalAlert goal) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar Metas e Prazos'),
            content: const Text('Aqui você poderá editar as metas no futuro.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

Future<void> _confirmarAporte(String goalId) async {
  final docRef = FirebaseFirestore.instance.collection('history').doc(goalId);
  final doc = await docRef.get();

  if (!doc.exists) return;

  final List<dynamic> items = doc['items'] ?? [];
  final List<Map<String, dynamic>> lista = List<Map<String, dynamic>>.from(items);

  // encontra o primeiro aporte não confirmado
  final index = lista.indexWhere((e) => e['confirmed'] != true);
  if (index == -1) return;

  lista[index]['confirmed'] = true;

  await docRef.update({'items': lista});
  _loadGoalAlerts(); // recarrega a lista
}

Future<void> _adicionarDepositoExtra(String goalId, double amount) async {
  final docRef = FirebaseFirestore.instance.collection('history').doc(goalId);
  final doc = await docRef.get();

  final now = DateTime.now();
  final retroDate = DateTime(now.year, now.month - 1, 1);

  final novoAporte = {
    'amount': amount,
    'confirmed': false,
    'timestamp': Timestamp.fromDate(retroDate),
    'month': '${retroDate.month.toString().padLeft(2, '0')}/${retroDate.year}',
  };

  if (doc.exists) {
    final List<dynamic> items = doc['items'] ?? [];
    final lista = List<Map<String, dynamic>>.from(items);
    lista.insert(0, novoAporte);
    await docRef.update({'items': lista});
  } else {
    await docRef.set({'items': [novoAporte]});
  }

  _loadGoalAlerts();
}

Future<void> _salvarAtraso(String goalId, String meta, DateTime ultimaData) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  await FirebaseFirestore.instance.collection('alerts').doc(goalId).set({
    'userId': userId,
    'goalId': goalId,
    'meta': meta,
    'lastDeposit': ultimaData,
    'alertedAt': FieldValue.serverTimestamp(),
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _goalAlerts.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhuma meta encontrada',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Crie suas metas de investimento\npara acompanhar os alertas aqui.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Check Depósito Mensal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _extraDeposit(goal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Depósito Extra'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'CONFIGURAÇÕES',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Montante estimado: R\$${goal.estimatedAmount.toStringAsFixed(2)}',
          ),
          Text(
            'Renda passiva estimada: R\$${goal.passiveIncome.toStringAsFixed(2)}',
          ),
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
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Icon(Icons.check_circle_outline),
      ],
    );
  }
}



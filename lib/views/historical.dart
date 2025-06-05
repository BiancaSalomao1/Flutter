import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoricalPage extends StatefulWidget {
  const HistoricalPage({super.key});

  @override
  State<HistoricalPage> createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  bool _loading = true;
  List<GoalHistoryModel> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadAllGoalsAndHistory();
  }

  // Método corrigido para evitar erro de índice composto
  Future<void> _loadAllGoalsAndHistory() async {
    try {
      // Primeiro, buscar todas as metas com valor > 0
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final goalsSnapshot =
          await FirebaseFirestore.instance
              .collection('goals')
              .where('userId', isEqualTo: userId)
              .where('deleted', isEqualTo: false)
              .where('monthly', isGreaterThan : 0)
              .get();

      final List<GoalHistoryModel> goalsWithHistory = [];

      for (var doc in goalsSnapshot.docs) {
        final data = doc.data();
        final goalId = doc.id;

        // Verificar se a meta foi apagada (filtro manual)
        final isDeleted = data['deleted'] ?? false;
        if (isDeleted) {
          continue; // Pular metas apagadas
        }

        final monthly = (data['monthly'] as num).toDouble();
        final title = data['category'] ?? 'Meta';

        final historyDoc =
            await FirebaseFirestore.instance
                .collection('history')
                .doc(goalId)
                .get();

        List<DepositEntry> history = [];
        if (historyDoc.exists) {
          final historyData = historyDoc.data();
          if (historyData != null && historyData.containsKey('items')) {
            final raw = List<Map<String, dynamic>>.from(historyData['items']);
            history =
                raw
                    .map(
                      (e) => DepositEntry(
                        month: e['month'],
                        amount: (e['amount'] as num).toDouble(),
                        confirmed: e['confirmed'] ?? false,
                        timestamp: (e['timestamp'] as Timestamp).toDate(),
                      ),
                    )
                    .toList();
          }
        }

        if (history.isEmpty) {
          history.add(_generateDeposit(monthly, DateTime.now()));
          await _saveHistory(goalId, history);
        } else {
          final last = history.last;
          final now = DateTime.now();
          final lastMonth = DateTime(last.timestamp.year, last.timestamp.month);
          final currentMonth = DateTime(now.year, now.month);

          final isNewMonth = currentMonth.isAfter(lastMonth);

          if (last.confirmed && isNewMonth) {
            final nextMonthDate = DateTime(
              last.timestamp.month == 12
                  ? last.timestamp.year + 1
                  : last.timestamp.year,
              last.timestamp.month == 12 ? 1 : last.timestamp.month + 1,
            );
            history.add(_generateDeposit(monthly, nextMonthDate));
            await _saveHistory(goalId, history);
          }
        }

        goalsWithHistory.add(
          GoalHistoryModel(
            goalId: goalId,
            title: title,
            monthly: monthly,
            history: history,
          ),
        );
      }

      setState(() {
        _goals = goalsWithHistory;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao carregar metas e histórico: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Método alternativo mais simples - apenas verifica se o documento existe
  Future<void> _loadAllGoalsAndHistorySimple() async {
    try {
      // Buscar todas as metas ativas (sem filtro de deleted para evitar índice composto)
      final goalsSnapshot =
          await FirebaseFirestore.instance
              .collection('goals')
              .where('monthly', isGreaterThan: 0)
              .get();

      final List<GoalHistoryModel> goalsWithHistory = [];

      for (var doc in goalsSnapshot.docs) {
        // Verificar se o documento ainda existe (re-fetch para garantir que não foi deletado)
        final docRef = FirebaseFirestore.instance
            .collection('goals')
            .doc(doc.id);
        final currentDoc = await docRef.get();

        if (!currentDoc.exists) {
          continue; // Pular se o documento foi completamente apagado
        }

        final data = currentDoc.data()!;
        final goalId = doc.id;
        final monthly = (data['monthly'] as num?)?.toDouble() ?? 0.0;

        // Se monthly for 0 ou negativo após a verificação, pular
        if (monthly <= 0) {
          continue;
        }

        final title = data['category'] ?? 'Meta';

        final historyDoc =
            await FirebaseFirestore.instance
                .collection('history')
                .doc(goalId)
                .get();

        List<DepositEntry> history = [];
        if (historyDoc.exists) {
          final historyData = historyDoc.data();
          if (historyData != null && historyData.containsKey('items')) {
            final raw = List<Map<String, dynamic>>.from(historyData['items']);
            history =
                raw
                    .map(
                      (e) => DepositEntry(
                        month: e['month'],
                        amount: (e['amount'] as num).toDouble(),
                        confirmed: e['confirmed'] ?? false,
                        timestamp: (e['timestamp'] as Timestamp).toDate(),
                      ),
                    )
                    .toList();
          }
        }

        if (history.isEmpty) {
          history.add(_generateDeposit(monthly, DateTime.now()));
          await _saveHistory(goalId, history);
        } else {
          final last = history.last;
          final now = DateTime.now();
          final lastMonth = DateTime(last.timestamp.year, last.timestamp.month);
          final currentMonth = DateTime(now.year, now.month);

          final isNewMonth = currentMonth.isAfter(lastMonth);

          if (last.confirmed && isNewMonth) {
            final nextMonthDate = DateTime(
              last.timestamp.month == 12
                  ? last.timestamp.year + 1
                  : last.timestamp.year,
              last.timestamp.month == 12 ? 1 : last.timestamp.month + 1,
            );
            history.add(_generateDeposit(monthly, nextMonthDate));
            await _saveHistory(goalId, history);
          }
        }

        goalsWithHistory.add(
          GoalHistoryModel(
            goalId: goalId,
            title: title,
            monthly: monthly,
            history: history,
          ),
        );
      }

      setState(() {
        _goals = goalsWithHistory;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao carregar metas e histórico: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  DepositEntry _generateDeposit(double monthly, DateTime date) {
    final formatted = _formatMonthYear(date);
    return DepositEntry(
      month: formatted,
      amount: monthly,
      confirmed: false,
      timestamp: date,
    );
  }

  Future<void> _saveHistory(String goalId, List<DepositEntry> history) async {
    await FirebaseFirestore.instance.collection('history').doc(goalId).set({
      'items': history.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> _confirmDeposit(String goalId, int index) async {
    final goal = _goals.firstWhere((g) => g.goalId == goalId);
    final history = goal.history;

    if (!history[index].confirmed) {
      history[index] = history[index].copyWith(confirmed: true);

      if (index == history.length - 1) {
        final lastTimestamp = history[index].timestamp;
        final nextMonthDate = DateTime(
          lastTimestamp.month == 12
              ? lastTimestamp.year + 1
              : lastTimestamp.year,
          lastTimestamp.month == 12 ? 1 : lastTimestamp.month + 1,
        );
        history.add(_generateDeposit(goal.monthly, nextMonthDate));
      }

      await _saveHistory(goalId, history);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Histórico de Depósitos'),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _goals.isEmpty
              ? _buildNoGoalsMessage()
              : ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, i) {
                  final goal = _goals[i];
                  return ExpansionTile(
                    title: Text(goal.title),
                    children:
                        goal.history.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return ListTile(
                            title: Text(item.month),
                            subtitle: Text(
                              'R\$${item.amount.toStringAsFixed(2)}',
                            ),
                            trailing: ElevatedButton(
                              onPressed:
                                  item.confirmed
                                      ? null
                                      : () =>
                                          _confirmDeposit(goal.goalId, index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    item.confirmed ? Colors.green : Colors.grey,
                                disabledBackgroundColor: Colors.green,
                              ),
                              child: const Text('Confirmar'),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
    );
  }

  Widget _buildNoGoalsMessage() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Nenhuma meta encontrada.'),
        SizedBox(height: 16),
        Icon(Icons.error_outline, size: 48, color: Colors.grey),
        SizedBox(height: 32),
        Text('Volte e crie sua primeira meta para começar!'),
      ],
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ---------------------- MODELOS ----------------------

class GoalHistoryModel {
  final String goalId;
  final String title;
  final double monthly;
  final List<DepositEntry> history;

  GoalHistoryModel({
    required this.goalId,
    required this.title,
    required this.monthly,
    required this.history,
  });
}

class DepositEntry {
  final String month;
  final double amount;
  final bool confirmed;
  final DateTime timestamp;

  DepositEntry({
    required this.month,
    required this.amount,
    required this.confirmed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'month': month,
    'amount': amount,
    'confirmed': confirmed,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  DepositEntry copyWith({bool? confirmed}) => DepositEntry(
    month: month,
    amount: amount,
    confirmed: confirmed ?? this.confirmed,
    timestamp: timestamp,
  );
}

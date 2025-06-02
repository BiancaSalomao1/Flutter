import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class GoalsPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const GoalsPage({super.key, this.data});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final Map<String, List<Map<String, dynamic>>> categorizedGoals = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndSaveNewGoal();
  }

  Future<void> _initFirebaseAndSaveNewGoal() async {
    try {
      await Firebase.initializeApp();
      print(' Firebase inicializado');

      // Se nova meta vier da calculadora, salva no banco ANTES de começar a escutar
      if (widget.data != null) {
        await FirebaseFirestore.instance.collection('goals').add(widget.data!);
        print('Meta salva: ${widget.data}');
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print(' Erro ao inicializar Firebase: $e');
      setState(() => _isLoading = false);
    }
  }

  Stream<Map<String, List<Map<String, dynamic>>>> _getGoalsStream() {
    return FirebaseFirestore.instance.collection('goals').snapshots().map((
      snapshot,
    ) {
      final Map<String, List<Map<String, dynamic>>> tempCategorizedGoals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // 👇 FILTRO que ignora metas marcadas como deletadas
        if (data['deleted'] == true) continue;

        data['id'] = doc.id;
        final category = data['category'] ?? 'Meta Padrão';
        tempCategorizedGoals[category] = [
          ...(tempCategorizedGoals[category] ?? []),
          data,
        ];
      }

      return tempCategorizedGoals;
    });
  }

  Future<void> _deleteGoal(String id, String category) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(id).update({
        'deleted': true,
      });
      print('Meta marcada como deletada: $id');
    } catch (e) {
      print('Erro ao marcar meta como deletada: $e');
    }
  }

  void _addCategory() {
    String newTitle = '';
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Nova categoria'),
            content: TextField(
              onChanged: (value) => newTitle = value,
              decoration: const InputDecoration(hintText: 'Ex: Viagem'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (newTitle.trim().isNotEmpty) {
                    // Cria uma meta dummy só para criar a categoria
                    FirebaseFirestore.instance.collection('goals').add({
                      'category': newTitle.trim(),
                      'finalAmount': 0,
                      'initial': 0,
                      'monthly': 0,
                      'months': 0,
                      'isDummy': true, // Flag para identificar categoria vazia
                    });
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _updateGoalCategory(
    String oldCategory,
    Map<String, dynamic> goal,
    String newCategory,
  ) async {
    final id = goal['id'];
    if (id != null) {
      await FirebaseFirestore.instance.collection('goals').doc(id).update({
        'category': newCategory,
      });
    }
  }

  // Função para converter valores para double
  double _convertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(onPressed: _addCategory, icon: const Icon(Icons.add)),
        ],
      ),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: _getGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final categorizedGoals = snapshot.data ?? {};

          if (categorizedGoals.isEmpty) {
            return const Center(child: Text('Nenhuma meta cadastrada ainda.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                categorizedGoals.entries.map((entry) {
                  final title = entry.key;
                  final goals =
                      entry.value
                          .where((goal) => goal['isDummy'] != true)
                          .toList();

                  return DragTarget<Map<String, dynamic>>(
                    onAccept: (goal) {
                      final oldCategory = goal['category'];
                      _updateGoalCategory(oldCategory, goal, title);
                    },
                    builder:
                        (context, _, __) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...goals.map((goal) {
                              // Convertendo os valores para double
                              final finalAmount = _convertToDouble(
                                goal['finalAmount'],
                              );
                              final initial = _convertToDouble(goal['initial']);
                              final monthly = _convertToDouble(goal['monthly']);
                              final months = goal['months'] ?? 0;

                              final totalAportes = initial + (monthly * months);
                              final totalJuros = finalAmount - totalAportes;

                              return Draggable<Map<String, dynamic>>(
                                data: goal,
                                feedback: Material(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.blue,
                                    child: Text(
                                      goal['category'] ?? 'Meta',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: const SizedBox.shrink(),
                                child: Card(
                                  child: ListTile(
                                    title: Text(goal['category'] ?? 'Meta'),
                                    subtitle: Text(
                                      'Montante: R\$ ${finalAmount.toStringAsFixed(2)}\n'
                                      'Aportes: R\$ ${totalAportes.toStringAsFixed(2)}\n'
                                      'Juros: R\$ ${totalJuros.toStringAsFixed(2)}\n'
                                      'Tempo: $months meses',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _deleteGoal(goal['id'], title);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                          ],
                        ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}

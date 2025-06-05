import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      print('✅ Firebase inicializado');
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Erro ao inicializar Firebase: $e');
      setState(() => _isLoading = false);
    }
  }

  Stream<Map<String, List<Map<String, dynamic>>>> _getGoalsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('🔍 UserId atual: $userId');

    if (userId == null) {
      print('❌ Usuário não está logado');
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .where('deleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final Map<String, List<Map<String, dynamic>>> tempCategorizedGoals =
              {};
          final Set<String> seenGoalIds = {}; // ← Para evitar duplicatas

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final goalId = doc.id;

            // Garante que só adicionamos metas reais, não dummies
            final isDummy = data['isDummy'] == true;
            final category = data['category'] ?? 'Meta Personalizada';

            data['id'] = goalId;

            // Garante que a categoria existe no mapa
            tempCategorizedGoals.putIfAbsent(category, () => []);

            if (!isDummy && !seenGoalIds.contains(goalId)) {
              tempCategorizedGoals[category]!.add(data);
              seenGoalIds.add(goalId);
            }
          }

          return tempCategorizedGoals;
        });
  }

  Future<void> _deleteGoal(String id, String category) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(id).update({
        'deleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Meta marcada como deletada: $id');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print(' Erro ao marcar meta como deletada: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover meta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (newTitle.trim().isNotEmpty) {
                    try {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        // Cria uma meta placeholder para a categoria
                        await FirebaseFirestore.instance
                            .collection('goals')
                            .add({
                              'category': newTitle.trim(),
                              'finalAmount': 0.0,
                              'initial': 0.0,
                              'monthly': 0.0,
                              'months': 0,
                              'rate': 0.0,
                              'totalInvested': 0.0,
                              'totalInterest': 0.0,
                              'isDummy': true,
                              'userId': userId,
                              'deleted': false,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                        print('✅ Nova categoria criada: $newTitle');
                      }
                    } catch (e) {
                      print('❌ Erro ao criar categoria: $e');
                    }
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
      try {
        await FirebaseFirestore.instance.collection('goals').doc(id).update({
          'category': newCategory,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Meta movida para categoria: $newCategory');
      } catch (e) {
        print('❌ Erro ao mover meta: $e');
      }
    }
  }

  // Função para converter valores para double
  double _convertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  void _showGoalDetails(Map<String, dynamic> goal) {
    final finalAmount = _convertToDouble(goal['finalAmount']);
    final initial = _convertToDouble(goal['initial']);
    final monthly = _convertToDouble(goal['monthly']);
    final months = goal['months'] ?? 0;
    final rate = _convertToDouble(goal['rate']);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(goal['category'] ?? 'Meta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰 Aporte inicial: R\$ ${initial.toStringAsFixed(2)}'),
                Text('📅 Aporte mensal: R\$ ${monthly.toStringAsFixed(2)}'),
                Text('⏱️ Período: $months meses'),
                Text('📈 Taxa: ${rate.toStringAsFixed(2)}% a.m.'),
                const Divider(),
                Text(
                  '🎯 Valor final: R\$ ${finalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando metas...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar categoria',
          ),
        ],
      ),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: _getGoalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando suas metas...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('❌ Erro no StreamBuilder: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _initFirebase();
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final categorizedGoals = snapshot.data ?? {};
          print('🎯 Metas categorizadas no build: $categorizedGoals');

          if (categorizedGoals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma meta cadastrada ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use a calculadora para criar sua primeira meta!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                categorizedGoals.entries.map((entry) {
                  final title = entry.key;
                  final goals = entry.value; // Removido o filtro adicional aqui

                  print(
                    '🔄 Processando categoria: $title com ${goals.length} metas',
                  );

                  return DragTarget<Map<String, dynamic>>(
                    onAccept: (goal) {
                      final oldCategory = goal['category'];
                      _updateGoalCategory(oldCategory, goal, title);
                    },
                    builder:
                        (context, candidateData, rejectedData) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border:
                                candidateData.isNotEmpty
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (goals.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Arraste metas para esta categoria',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ...goals.map((goal) {
                                print(
                                  '🎨 Renderizando meta: ${goal['category']} - ${goal['finalAmount']}',
                                );

                                final finalAmount = _convertToDouble(
                                  goal['finalAmount'],
                                );
                                final initial = _convertToDouble(
                                  goal['initial'],
                                );
                                final monthly = _convertToDouble(
                                  goal['monthly'],
                                );
                                final months = goal['months'] ?? 0;

                                final totalAportes =
                                    initial + (monthly * months);
                                final totalJuros = finalAmount - totalAportes;

                                return Draggable<Map<String, dynamic>>(
                                  data: goal,
                                  feedback: Material(
                                    elevation: 6,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 200,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        goal['category'] ?? 'Meta',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: Card(
                                      margin: const EdgeInsets.all(8),
                                      child: ListTile(
                                        title: Text(goal['category'] ?? 'Meta'),
                                        subtitle: const Text('Movendo...'),
                                      ),
                                    ),
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.all(8),
                                    elevation: 2,
                                    child: ListTile(
                                      onTap: () => _showGoalDetails(goal),
                                      title: Text(
                                        goal['category'] ?? 'Meta',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmar exclusão',
                                                  ),
                                                  content: const Text(
                                                    'Tem certeza que deseja excluir esta meta?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteGoal(
                                                          goal['id'],
                                                          title,
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Excluir',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}

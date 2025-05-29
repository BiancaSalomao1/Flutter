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
    _initFirebaseAndLoadGoals();
  }

  Future<void> _initFirebaseAndLoadGoals() async {
    try {
      await Firebase.initializeApp(); // Garante que Firebase está inicializado
      print('✅ Firebase inicializado');
      await _loadGoals();
    } catch (e) {
      print('❌ Erro ao inicializar Firebase: $e');
    }
  }

  Future<void> _loadGoals() async {
    try {
      categorizedGoals.clear();

      final snapshot = await FirebaseFirestore.instance.collection('goals').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final category = data['category'] ?? 'Meta Padrão';
        categorizedGoals[category] = [...(categorizedGoals[category] ?? []), data];
      }

      // Se nova meta vier da calculadora, salva no banco
      if (widget.data != null) {
        final doc = await FirebaseFirestore.instance.collection('goals').add(widget.data!);
        final newGoal = {...widget.data!, 'id': doc.id};
        final category = newGoal['category'] ?? 'Meta Padrão';
        categorizedGoals[category] = [...(categorizedGoals[category] ?? []), newGoal];
        print('✅ Meta salva: $newGoal');
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Erro ao carregar metas: $e');
    }
  }

  Future<void> _deleteGoal(String id, String category) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(id).delete();
      setState(() {
        categorizedGoals[category]?.removeWhere((goal) => goal['id'] == id);
      });
      print('🗑️ Meta deletada: $id');
    } catch (e) {
      print('❌ Erro ao deletar meta: $e');
    }
  }

  void _addCategory() {
    String newTitle = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: TextField(
          onChanged: (value) => newTitle = value,
          decoration: const InputDecoration(hintText: 'Ex: Viagem'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (newTitle.trim().isNotEmpty && !categorizedGoals.containsKey(newTitle)) {
                setState(() => categorizedGoals[newTitle.trim()] = []);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateGoalCategory(String oldCategory, Map<String, dynamic> goal, String newCategory) async {
    final id = goal['id'];
    if (id != null) {
      await FirebaseFirestore.instance.collection('goals').doc(id).update({'category': newCategory});
      setState(() {
        categorizedGoals[oldCategory]?.remove(goal);
        goal['category'] = newCategory;
        categorizedGoals[newCategory] = [...(categorizedGoals[newCategory] ?? []), goal];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(onPressed: _addCategory, icon: const Icon(Icons.add)),
        ],
      ),
      body: categorizedGoals.isEmpty
          ? const Center(child: Text('Nenhuma meta cadastrada ainda.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: categorizedGoals.entries.map((entry) {
                final title = entry.key;
                final goals = entry.value;

                return DragTarget<Map<String, dynamic>>(
                  onAccept: (goal) {
                    final oldCategory = goal['category'];
                    _updateGoalCategory(oldCategory, goal, title);
                  },
                  builder: (context, _, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...goals.map((goal) {
                        final aporte = goal['initial'] + (goal['monthly'] * goal['months']);
                        final juros = goal['finalAmount'] - aporte;

                        return Draggable<Map<String, dynamic>>(
                          data: goal,
                          feedback: Material(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.blue,
                              child: Text(goal['category'] ?? 'Meta', style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          child: Card(
                            child: ListTile(
                              title: Text(goal['category'] ?? 'Meta'),
                              subtitle: Text(
                                'Montante: R\$ ${goal['finalAmount'].toStringAsFixed(2)}\n'
                                'Aportes: R\$ ${aporte.toStringAsFixed(2)}\n'
                                'Juros: R\$ ${juros.toStringAsFixed(2)}\n'
                                'Tempo: ${goal['months']} meses',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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
            ),
    );
  }
}

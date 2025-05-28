import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';
import 'goal_detail_page.dart';


class GoalListPage extends StatelessWidget {
  const GoalListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Metas')),
      body: StreamBuilder<List<Goal>>(
        stream: streamGoalsByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar metas.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data!;
          if (goals.isEmpty) {
            return const Center(child: Text('Nenhuma meta cadastrada.'));
          }

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return ListTile(
                title: Text(goal.title),
                subtitle: Text(
                  'Alvo: R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  'Projeção: R\$ ${goal.calculateProjection().toStringAsFixed(2)}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GoalDetailPage(goal: goal),
                    ),
                  );
                },
                onLongPress: () {
                  // Implementar remoção de meta
                  // goalController.removeGoal(goal.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Meta "${goal.title}" removida.')),
                  );
                },
           ); },
          );
        },
      ),
    );
  }
}

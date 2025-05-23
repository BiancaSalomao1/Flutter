import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/goal_controller.dart';
import '../models/goal.dart';
import 'dart:math';

class GoalFormPage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController initialController = TextEditingController();
  final TextEditingController monthlyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  GoalFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GoalController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Goal Title')),
          TextField(controller: initialController, decoration: const InputDecoration(labelText: 'Initial Amount'), keyboardType: TextInputType.number),
          TextField(controller: monthlyController, decoration: const InputDecoration(labelText: 'Monthly Contribution'), keyboardType: TextInputType.number),
          TextField(controller: rateController, decoration: const InputDecoration(labelText: 'Interest Rate (%)'), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final goal = Goal(
                id: Random().nextInt(999999).toString(),
                userId: 'userId', // simulado
                title: titleController.text,
                initialAmount: double.parse(initialController.text),
                targetAmount: 0,
                monthlyContribution: double.parse(monthlyController.text),
                interestRate: double.parse(rateController.text),
                durationMonths: 12,
              );
              controller.addGoal(goal);
              Navigator.pop(context);
            },
            child: const Text('Add Goal'),
          )
        ]),
      ),
    );
  }
}

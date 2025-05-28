import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/aporte.dart';
import '../services/aporte_service.dart';

class GoalDetailPage extends StatelessWidget {
  final Goal goal;

  const GoalDetailPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final aporteService = AporteService();

    return Scaffold(
      appBar: AppBar(title: Text(goal.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Valor Projetado'),
            subtitle: Text('R\$ ${goal.calculateProjection().toStringAsFixed(2)}'),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Aportes realizados:', style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: StreamBuilder<List<Aporte>>(
              stream: aporteService.getAportesByGoal(goal.id!),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Erro ao carregar aportes.');
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final aportes = snapshot.data!;
                if (aportes.isEmpty) return const Text('Nenhum aporte feito ainda.');

                return ListView.builder(
                  itemCount: aportes.length,
                  itemBuilder: (context, index) {
                    final aporte = aportes[index];
                    return ListTile(
                      title: Text('R\$ ${aporte.amount.toStringAsFixed(2)}'),
                      subtitle: Text('Data: ${aporte.date.toLocal().toString().split(' ')[0]}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarAporteDialog(context, goal),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _adicionarAporteDialog(BuildContext context, Goal goal) {
    final TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Aporte'),
        content: TextField(
          controller: valorController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Valor do aporte'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Adicionar'),
            onPressed: () async {
              final valor = double.tryParse(valorController.text);
              if (valor != null && valor > 0) {
                final novoAporte = Aporte(
                  id: '',
                  goalId: goal.id!,
                  amount: valor,
                  date: DateTime.now(),
                );
                await AporteService().addAporte(novoAporte);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

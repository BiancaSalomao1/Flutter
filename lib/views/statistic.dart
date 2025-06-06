import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appeducafin/views/projection.dart';
import 'package:appeducafin/views/report.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:appeducafin/views/historical.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticDashboard extends StatefulWidget {
  const StatisticDashboard({super.key});

  @override
  State<StatisticDashboard> createState() => _StatisticDashboardState();
}

class _StatisticDashboardState extends State<StatisticDashboard> {
  double totalEntradas = 0;
  double totalJuros = 0;
  List<FlSpot> montanteSpots = [];
  List<FlSpot> entradaSpots = [];

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final historySnapshot = await FirebaseFirestore.instance
        .collection('history')
        .get(); // sem filtro por userId

    final goalsSnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .where('userId', isEqualTo: user.uid)
        .where('deleted', isEqualTo: false)
        .get();

    Map<String, double> goalRates = {};
    for (var doc in goalsSnapshot.docs) {
      final data = doc.data();
      final rate = (data['rate'] ?? 0.0).toDouble();
      goalRates[doc.id] = rate;
    }

    Map<int, double> entradasPorMes = {};
    Map<int, double> montantePorMes = {};
    double totalEntradas = 0;
    double totalJuros = 0;

    for (var doc in historySnapshot.docs) {
      final goalId = doc.id;

      if (!goalRates.containsKey(goalId)) {
        print('⚠️ Ignorado: meta $goalId não encontrada ou sem taxa.');
        continue;
      }

      final rate = goalRates[goalId]!;
      final List<dynamic>? items = doc['items'];

      if (items == null || items.isEmpty) continue;

      final List<DepositEntry> confirmed = items
          .map(
            (e) => DepositEntry(
              month: e['month'],
              amount: (e['amount'] as num).toDouble(),
              confirmed: e['confirmed'] == true,
              timestamp: (e['timestamp'] as Timestamp).toDate(),
            ),
          )
          .where((entry) => entry.confirmed)
          .toList();

      if (confirmed.isEmpty) continue;

      confirmed.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      double montanteAcumulado = 0;

      for (var entry in confirmed) {
        final monthIndex = (entry.timestamp.year * 12) + entry.timestamp.month;

        // Entradas
        totalEntradas += entry.amount;
        entradasPorMes[monthIndex] =
            (entradasPorMes[monthIndex] ?? 0) + entry.amount;

        // Juros compostos
        montanteAcumulado = montanteAcumulado * (1 + rate / 100) + entry.amount;
        montantePorMes[monthIndex] = montanteAcumulado;

        final jurosDoMes = montanteAcumulado - totalEntradas;
        totalJuros = jurosDoMes < 0 ? 0 : jurosDoMes;
      }
    }

    final sortedMeses = entradasPorMes.keys.toList()..sort();
    double acumuladoEntradas = 0;
    final entradaSpots = <FlSpot>[];
    final montanteSpots = <FlSpot>[];

    for (int i = 0; i < sortedMeses.length; i++) {
      final mes = sortedMeses[i];
      final entrada = entradasPorMes[mes]!;
      acumuladoEntradas += entrada;

      entradaSpots.add(FlSpot(i.toDouble(), acumuladoEntradas));
      montanteSpots.add(FlSpot(i.toDouble(), montantePorMes[mes]!));
    }

    setState(() {
      this.totalEntradas = totalEntradas;
      this.totalJuros = totalJuros;
      this.entradaSpots = entradaSpots;
      this.montanteSpots = montanteSpots;
    });
  } catch (e) {
    print('Erro ao carregar dados financeiros: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final double montanteTotal = totalEntradas + totalJuros;
    final double crescimento =
        totalEntradas > 0
            ? ((montanteTotal - totalEntradas) / totalEntradas) * 100
            : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(" "),
          _buildTotalAmountCard(montanteTotal, crescimento),
          const SizedBox(height: 16),
          _buildCardsRow(context),
          const SizedBox(height: 16),
          _buildStatisticsChart(),
          const SizedBox(height: 16),
          //buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildTotalAmountCard(double montante, double crescimento) {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Montante Total',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$${montante.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Taxa de Crescimento +${crescimento.toStringAsFixed(2)}%',
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            Icons.input,
            Colors.pink,
            'Entradas',
            'R\$${totalEntradas.toStringAsFixed(2)}',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            Icons.monetization_on,
            Colors.yellow,
            'Juros',
            'R\$${totalJuros.toStringAsFixed(2)}',
          ),
        ),
        if (MediaQuery.of(context).size.width > 600) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoCard(
              Icons.trending_up,
              Colors.green,
              'Rendimento',
              '+${((totalJuros / (totalEntradas == 0 ? 1 : totalEntradas)) * 100).toStringAsFixed(2)}%',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Estatística',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 12,
                  minY: 0,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: montanteSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    LineChartBarData(
                      spots: entradaSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildNavigationButtons(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       ElevatedButton(
  //         onPressed:
  //             () => Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => const Report()),
  //             ),
  //         child: const Text('Relatório'),
  //       ),
  //       ElevatedButton(
  //         onPressed:
  //             () => Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => const ProjectionPage()),
  //             ),
  //         child: const Text('Projeção'),
  //       ),
  //     ],
  //   );
  // }
}

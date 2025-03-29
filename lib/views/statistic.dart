import 'package:appeducafin/controllers/bottom_navegation.dart';
import 'package:appeducafin/views/projection.dart';
import 'package:appeducafin/views/report.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticDashboard extends StatefulWidget {
  const StatisticDashboard({super.key});

  @override
  _StatisticDashboardState createState() => _StatisticDashboardState();
}

class _StatisticDashboardState extends State<StatisticDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Placeholder pages, substitute as necessary
    const Center(child: Text("Metas")),
    const Center(child: Text("Calculadora de Juros Compostos")),
    const Center(child: Text("Conteúdo Educacional")),
    const Report(), // Update with your actual page
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("conteúdo do texto"),
              _buildTotalAmountCard(),
              const SizedBox(height: 16),
              _buildCardsRow(context),
              const SizedBox(height: 16),
              _buildStatisticsChart(),
              const SizedBox(height: 16),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // Set the current index
        onTap: _onTabTapped, // Handle tap on bottom navigation items
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Card(
      color: Colors.black,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montante Total', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 8),
            Text('R\$94.395,00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Taxa de Crescimento +6.02%', style: TextStyle(color: Colors.green, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildEntriesCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildInterestCard()),
        if (MediaQuery.of(context).size.width > 600) ...[
          const SizedBox(width: 16),
          Expanded(child: _buildExtraCard()),
        ],
      ],
    );
  }

  Widget _buildEntriesCard() {
    return _buildInfoCard(Icons.input, Colors.pink, 'Entradas', 'R\$87.594,00');
  }

  Widget _buildInterestCard() {
    return _buildInfoCard(Icons.monetization_on, Colors.yellow, 'Juros', 'R\$7.792,00');
  }

  Widget _buildExtraCard() {
    return _buildInfoCard(Icons.trending_up, Colors.green, 'Rendimento', '+6.02%');
  }

  Widget _buildInfoCard(IconData icon, Color color, String title, String value) {
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            const Text('Estatística', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 10), FlSpot(1, 20), FlSpot(2, 30),
                        FlSpot(3, 45), FlSpot(4, 65), FlSpot(5, 80), FlSpot(6, 94),
                      ],
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.3)),
                    ),
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 10), FlSpot(1, 15), FlSpot(2, 25),
                        FlSpot(3, 40), FlSpot(4, 55), FlSpot(5, 70), FlSpot(6, 90),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
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

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Report()),
          ),
          child: const Text('Relatório'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectionPage()),
          ),
          child: const Text('Projeção'),
        ),
      ],
    );
  }
}

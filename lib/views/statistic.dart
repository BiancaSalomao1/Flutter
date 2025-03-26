import 'package:appeducafin/views/home.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:appeducafin/views/goals.dart';
import 'package:appeducafin/views/historical.dart';
import 'package:appeducafin/views/calculator.dart';
import 'package:appeducafin/views/report.dart';
import 'package:appeducafin/views/project.dart';

class InvestmentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estatísticas'),
        backgroundColor: Colors.black,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTotalAmountCard(),
                    SizedBox(height: 16),
                    _buildCardsRow(context),
                    SizedBox(height: 16),
                    _buildStatisticsChart(),
                    SizedBox(height: 16),
                    _buildNavigationButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context), // Added missing bottom navigation
    );
  }

  // The rest of the methods remain the same...

  // Move the methods before the build method
  Widget _buildTotalAmountCard() {
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
        SizedBox(width: 16),
        Expanded(child: _buildInterestCard()),
        SizedBox(width: 16),
        if (MediaQuery.of(context).size.width > 600) Expanded(child: _buildExtraCard()),
      ],
    );
  }

  Widget _buildEntriesCard() {
    return Card(
      color: Colors.pink[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.input, color: Colors.pink),
            SizedBox(height: 8),
            Text('Entradas', style: TextStyle(fontSize: 16)),
            Text('R\$87.594,00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestCard() {
    return Card(
      color: Colors.yellow[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.monetization_on, color: Colors.yellow),
            SizedBox(height: 8),
            Text('Juros', style: TextStyle(fontSize: 16)),
            Text('R\$7.792,00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraCard() {
    return Card(
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.trending_up, color: Colors.green),
            SizedBox(height: 8),
            Text('Rendimento', style: TextStyle(fontSize: 16)),
            Text('+6.02%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
            Text(
              'Estatística',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
  height: 250,
  child: LineChart(
    LineChartData(
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(fontSize: 10);
              switch (value.toInt()) {
                case 0: return Text('Jan', style: style);
                case 2: return Text('Mar', style: style);
                case 4: return Text('Mai', style: style);
                case 6: return Text('Jul', style: style);
                default: return Text('', style: style);
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}%', style: TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 10),
            FlSpot(1, 20),
            FlSpot(2, 30),
            FlSpot(3, 45),
            FlSpot(4, 65),
            FlSpot(5, 80),
            FlSpot(6, 94),
          ],
          isCurved: true,
          color: Colors.red,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red,
          ),
        ),
        LineChartBarData(
          spots: [
            FlSpot(0, 10),
            FlSpot(1, 15),
            FlSpot(2, 25),
            FlSpot(3, 40),
            FlSpot(4, 55),
            FlSpot(5, 70),
            FlSpot(6, 90),
          ],
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue,
          ),
        ),
      ],
    ),
  ),
)],
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
            MaterialPageRoute(builder: (context) => Report()),
          ),
          child: Text('Relatório'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estatística'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculadora'),
      ],
      currentIndex: 2, // Modifique dinamicamente conforme a tela ativa
      onTap: (index) {
        switch (index) {
          case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage())); break;
         // case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => Goals())); break;
          case 2: break; // Já estamos na InvestmentDashboard
         // case 3: Navigator.push(context, MaterialPageRoute(builder: (context) => Calculator())); break;
          default: break;
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProjectionPage extends StatefulWidget {
  const ProjectionPage({Key? key}) : super(key: key);

  @override
  _ProjectionPageState createState() => _ProjectionPageState();
}

class _ProjectionPageState extends State<ProjectionPage> {
  bool _isActualActive = true;
  List<double> _actualData = [0, 3000, 5000, 7000, 8000, 10000, 12000, 15000, 20000];
  List<double> _projectedData = [0, 3500, 5500, 7500, 8500, 10500, 12500, 15500, 21000];

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text('Projeção'),
      backgroundColor: Colors.blue, // opcional
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvestmentCard(),
          const SizedBox(height: 16),
          _buildLineChart(),
          const SizedBox(height: 16),
          _buildProjectionDetails(),
        ],
      ),
    ),
  );
}

  Widget _buildInvestmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CDB Banco C3 Multimercado',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildSegmentButton('Atual', _isActualActive, () {
                  setState(() {
                    _isActualActive = true;
                  });
                }),
                const SizedBox(width: 8),
                _buildSegmentButton('Projetado', !_isActualActive, () {
                  setState(() {
                    _isActualActive = false;
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    _buildChartBarData(
                      _isActualActive ? _actualData : _projectedData,
                      _isActualActive ? Colors.blue : Colors.green,
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

  LineChartBarData _buildChartBarData(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(values.length, (index) => FlSpot(index.toDouble(), values[index])),
      isCurved: true,
      color: color,
    );
  }

  Widget _buildSegmentButton(String text, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.grey[200],
          foregroundColor: isActive ? Colors.white : Colors.black,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildProjectionDetails() {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROJEÇÃO RENDA PASSIVA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Aportes até o momento:', currencyFormatter.format(12000.00)),
            _buildDetailRow('Juros já obtidos:', currencyFormatter.format(300.00)),
            _buildDetailRow('Tempo aplicado:', '12 meses'),
            const Divider(),
            _buildDetailRow('Aporte do Mês:', currencyFormatter.format(800.00)),
            _buildDetailRow('Juros estimados a somar:', currencyFormatter.format(9.80)),
            const Divider(),
            _buildDetailRow('Montante estimado:', currencyFormatter.format(2000000.00), isBold: true),
            _buildDetailRow('Renda passiva estimada:', currencyFormatter.format(2000.00), isBold: true),
            _buildDetailRow('Tempo restante:', '3 anos e 4 meses', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

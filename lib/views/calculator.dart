import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appeducafin/views/goals.dart';

class CalculatorPage extends StatefulWidget {
  final double? initialAmount;
  final int? months;
  final double? interestRate;

  const CalculatorPage({
    super.key,
    this.initialAmount,
    this.months,
    this.interestRate,
  });

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _initialController = TextEditingController();
  final _monthlyController = TextEditingController(text: '500');
  final _monthsController = TextEditingController();
  final _interestController = TextEditingController();

  double _finalAmount = 0;
  double _totalInvested = 0;
  double _totalInterest = 0;
  List<FlSpot> _chartData = [];

  @override
  void initState() {
    super.initState();
    _initialController.text =
        widget.initialAmount?.toStringAsFixed(0) ?? '1000';
    _monthsController.text = widget.months?.toString() ?? '120';
    _interestController.text =
        widget.interestRate?.toStringAsFixed(2) ?? '1.14';
    _calculate();
  }

  void _calculate() {
    final double initial = double.tryParse(_initialController.text) ?? 0;
    final double monthly = double.tryParse(_monthlyController.text) ?? 0;
    final int months = int.tryParse(_monthsController.text) ?? 0;
    final double interest =
        (double.tryParse(_interestController.text) ?? 0) / 100;

    double total = initial;
    final List<FlSpot> spots = [];
    final int interval = max(1, months ~/ 6);

    for (int i = 0; i <= months; i += interval) {
      total = initial;
      for (int j = 0; j < i; j++) {
        total = total * (1 + interest) + monthly;
      }
      spots.add(FlSpot(i.toDouble(), total));
    }

    final double totalInvested = initial + (monthly * months);
    final double interestGained = total - totalInvested;

    setState(() {
      _finalAmount = total;
      _totalInvested = totalInvested;
      _totalInterest = interestGained;
      _chartData = spots;
    });
  }

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _monthsController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CalculatorContent(
        formKey: _formKey,
        initialController: _initialController,
        monthlyController: _monthlyController,
        monthsController: _monthsController,
        interestController: _interestController,
        finalAmount: _finalAmount,
        totalInvested: _totalInvested,
        totalInterest: _totalInterest,
        chartData: _chartData,
        onCalculate: _calculate,
      ),
    );
  }
}

class CalculatorContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController initialController;
  final TextEditingController monthlyController;
  final TextEditingController monthsController;
  final TextEditingController interestController;
  final double finalAmount;
  final double totalInvested;
  final double totalInterest;
  final List<FlSpot> chartData;
  final VoidCallback onCalculate;

  const CalculatorContent({
    super.key,
    required this.formKey,
    required this.initialController,
    required this.monthlyController,
    required this.monthsController,
    required this.interestController,
    required this.finalAmount,
    required this.totalInvested,
    required this.totalInterest,
    required this.chartData,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildInput('APORTE INICIAL', initialController, prefix: 'R\$'),
            const SizedBox(height: 8),
            _buildInput('APORTE MENSAL', monthlyController, prefix: 'R\$'),
            const SizedBox(height: 8),
            _buildInput('TEMPO EM MESES', monthsController),
            const SizedBox(height: 8),
            _buildInput('TAXA DE JUROS (a.m)', interestController, suffix: '%'),
            const SizedBox(height: 16),
            _buildEstimateBox(context),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onCalculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('CALCULAR', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 16),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Calculadora\nJuros Compostos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Icon(Icons.calculate_outlined, size: 30),
      ],
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    String? prefix,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixText: prefix,
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimateBox(BuildContext context) {
    final double initial = double.tryParse(initialController.text) ?? 0;
    final double monthly = double.tryParse(monthlyController.text) ?? 0;
    final int months = int.tryParse(monthsController.text) ?? 0;
    final double rate = double.tryParse(interestController.text) ?? 0;
    final double result = finalAmount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'R\$ ${finalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Salvar Meta',
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              final newGoal = {
                'initial': initial,
                'monthly': monthly,
                'months': months,
                'rate': rate,
                'finalAmount': result,
                'category': 'Meta Personalizada',
                'deleted': false,
                'userId': userId,
                'createdAt': DateTime.now().toIso8601String(),
              };

              try {
                await FirebaseFirestore.instance
                    .collection('goals')
                    .add(newGoal);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meta salva com sucesso!')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar meta: \$e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.black,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'RESUMO\n'
        'Aportes: R\$ ${totalInvested.toStringAsFixed(2)}\n'
        'Juros: R\$ ${totalInterest.toStringAsFixed(2)}\n'
        'Tempo: ${monthsController.text} meses',
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

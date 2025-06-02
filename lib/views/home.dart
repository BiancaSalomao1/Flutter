import 'dart:math';
import 'package:appeducafin/views/statistic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appeducafin/controllers/bottom_navegation.dart';
import 'package:appeducafin/views/about.dart';
import 'package:appeducafin/views/alert.dart';
import 'package:appeducafin/views/calculator.dart';
import 'package:appeducafin/views/educational.dart';
import 'package:appeducafin/views/goals.dart';
import 'package:appeducafin/views/historical.dart';
import 'package:appeducafin/views/sugestions.dart';
import 'package:provider/provider.dart';
import '../controllers/quote_controller.dart';
import 'package:appeducafin/views/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomeContent(),
    const GoalsPage(),
    const StatisticDashboard(),
    const CalculatorPage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  Future<Map<String, double>> _calcularJurosDasMetas() async {
    final historySnapshot = await FirebaseFirestore.instance.collection('history').get();

    double totalConfirmado = 0;
    double totalJuros = 0;

    for (var doc in historySnapshot.docs) {
      final goalId = doc.id;
      print('Verificando histórico para meta: $goalId');

      final goalDoc = await FirebaseFirestore.instance
          .collection('goals')
          .doc(goalId)
          .get();

      if (!goalDoc.exists || (goalDoc.data()?['deleted'] == true)) {
        print('Meta $goalId não encontrada ou marcada como deletada - ignorando.');
        continue;
      }

      final historyItems = List<Map<String, dynamic>>.from(doc['items']);
      final confirmedDeposits = historyItems
          .where((item) => item['confirmed'] == true)
          .map((item) => (item['amount'] as num).toDouble())
          .toList();

      final double somaConfirmada = confirmedDeposits.fold(0, (a, b) => a + b);
      totalConfirmado += somaConfirmada;

      final goalData = goalDoc.data()!;
      final taxa = (goalData['rate'] ?? 0).toDouble();
      final juros = somaConfirmada * (taxa / 100);
      print('Juros da meta $goalId com taxa $taxa%: $juros');
      totalJuros += juros;
    }

    return {'montante': totalConfirmado, 'juros': totalJuros};
  }

  @override
  Widget build(BuildContext context) {
    void navigateTo(int index) {
      final homeState = context.findAncestorStateOfType<_HomePageState>();
      homeState?._onTabTapped(index);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Olá!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Bom ver você aqui.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertPage()),
              ),
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/bell.png'),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, double>>(
              future: _calcularJurosDasMetas(),
              builder: (context, snapshot) {
                final montante = snapshot.data?['montante'] ?? 0;
                final juros = snapshot.data?['juros'] ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCard(
                      'Depósitos Confirmados',
                      'R\$${montante.toStringAsFixed(2)}',
                      Colors.black,
                    ),
                    _buildCard(
                      'Juros Compostos',
                      'R\$${juros.toStringAsFixed(2)}',
                      Colors.pinkAccent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.shield, 'Metas', () => navigateTo(1)),
                  _buildMenuItem(Icons.bar_chart, 'Estatísticas', () => navigateTo(2)),
                  _buildMenuItem(
                    Icons.school,
                    'Conteúdo Educacional',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EducationalContentPage()),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.note_alt,
                    'Sugestões',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => QuoteController(),
                          child: InvestmentSuggestionsPage(),
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.list,
                    'Histórico',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoricalPage()),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.search,
                    'Pesquisa',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PesquisaPage()),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.nordic_walking,
                    'Sobre Nós',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String amount, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        leading: Icon(icon, color: Colors.pinkAccent),
        title: Text(title),
        tileColor: Colors.pink.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

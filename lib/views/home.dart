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
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    corrigirUserIdEmHistory();
  }

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

  Future<void> corrigirUserIdEmHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuário não autenticado.');
      return;
    }

    final historyCollection = FirebaseFirestore.instance.collection('history');
    final snapshot = await historyCollection.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('userId')) {
        print('Documento ${doc.id} já tem userId');
        continue;
      }

      await doc.reference.update({'userId': user.uid});
      print('Adicionado userId em ${doc.id}');
    }
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'montante': 0, 'juros': 0};

    final historySnapshot =
        await FirebaseFirestore.instance
            .collection('history')
            .where('userId', isEqualTo: user.uid)
            .get();

    final goalsSnapshot =
        await FirebaseFirestore.instance
            .collection('goals')
            .where('userId', isEqualTo: user.uid)
            .where('deleted', isEqualTo: false)
            .get();

    Map<String, Map<String, double>> goalDataMap = {};
    for (var doc in goalsSnapshot.docs) {
      final data = doc.data();
      final rate = (data['rate'] ?? 0.0).toDouble();
      final initial = (data['initial'] ?? 0.0).toDouble();
      goalDataMap[doc.id] = {'rate': rate, 'initial': initial};
    }

    double totalEntradas = 0;
    double totalJuros = 0;

    for (var doc in historySnapshot.docs) {
      final goalId = doc.id;

      if (!goalDataMap.containsKey(goalId)) {
        continue;
      }

      final rate = goalDataMap[goalId]!['rate']!;
      final initial = goalDataMap[goalId]!['initial']!;

      final data = doc.data();
      if (data['items'] == null) continue;

      final List<dynamic> items = data['items'];
      final List<Map<String, dynamic>> confirmed =
          items
              .where((item) => item['confirmed'] == true)
              .cast<Map<String, dynamic>>()
              .toList();

      if (confirmed.isEmpty) continue;

      confirmed.sort((a, b) {
        final t1 = (a['timestamp'] as Timestamp).toDate();
        final t2 = (b['timestamp'] as Timestamp).toDate();
        return t1.compareTo(t2);
      });

      double montanteAcumulado = initial;
      totalEntradas += initial;

      for (var item in confirmed) {
        final amount = (item['amount'] as num).toDouble();
        totalEntradas += amount;
        montanteAcumulado = montanteAcumulado * (1 + rate / 100) + amount;
      }

      final juros = montanteAcumulado - totalEntradas;
      totalJuros += juros < 0 ? 0 : juros;
    }

    return {'montante': totalEntradas, 'juros': totalJuros};
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
              onTap:
                  () => Navigator.push(
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // ou shimmer
                }
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }

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
                  _buildMenuItem(
                    Icons.bar_chart,
                    'Estatísticas',
                    () => navigateTo(2),
                  ),
                  _buildMenuItem(
                    Icons.school,
                    'Conteúdo Educacional',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EducationalContentPage(),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.note_alt,
                    'Sugestões',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChangeNotifierProvider(
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16,
        ),
        leading: Icon(icon, color: Colors.pinkAccent),
        title: Text(title),
        tileColor: Colors.pink.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

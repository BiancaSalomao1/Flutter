import 'package:appeducafin/controllers/bottom_navegation.dart';
import 'package:appeducafin/views/about.dart';
import 'package:appeducafin/views/alert.dart';
import 'package:appeducafin/views/calculator.dart';
import 'package:appeducafin/views/educational.dart';
import 'package:appeducafin/views/goals.dart';
import 'package:appeducafin/views/historical.dart';
import 'package:appeducafin/views/sugestions.dart';
import 'package:flutter/material.dart';
import 'package:appeducafin/views/statistic.dart';

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
                  'Oi, Fulana!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Bom Dia. Bom ver você aqui.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertPage()),
                );
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard('Metas Mensal', 'R\$5.982,00', Colors.black),
                _buildCard('Juros Compostos', 'R\$982,00', Colors.pinkAccent),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [_buildMenuItem(Icons.shield, 'Metas', () => navigateTo(1)),

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
      builder: (context) => const EducationalContentPage(),
    ),
  ),
),

_buildMenuItem(
  Icons.note_alt,
  'Sugestões',
  () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const InvestmentSuggestionsPage(),
    ),
  ),
),

_buildMenuItem(
  Icons.list,
  'Histórico',
  () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HistoricalPage(),
    ),
  ),
),

_buildMenuItem(
  Icons.nordic_walking,
  'Sobre Nós',
  () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AboutPage(),
    ),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(title),
      tileColor: Colors.pink.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}

import 'package:appeducafin/controllers/bottom_navegation.dart';
import 'package:flutter/material.dart';
import 'package:appeducafin/views/projection.dart'; // Import the new page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Placeholder pages for navigation
  final List<Widget> _pages = [
    const Center(child: Text("Metas")),
    const Center(child: Text("Calculadora de Juros Compostos")),
    const Center(child: Text("Conteúdo Educacional")),
    const ProjectionPage(), // Use the new page here
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Oi, Fulana!',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const Text('Bom Dia. Bom ver você aqui.',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            )
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
            const Text('Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.shield, 'Metas', () => _onTabTapped(0)),
                  _buildMenuItem(Icons.flash_on, 'Calculadora de Juros Compostos', () => _onTabTapped(1)),
                  _buildMenuItem(Icons.school, 'Conteúdo Educacional', () => _onTabTapped(2)),
                  _buildMenuItem(Icons.money, 'Renda Passiva', () => _onTabTapped(3)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(  // Use CustomBottomNavigationBar here
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(amount,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
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

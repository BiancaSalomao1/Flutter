import 'package:flutter/material.dart';
import 'package:appeducafin/views/home.dart'; // Adicione a página Home
import 'package:appeducafin/views/goals.dart'; // Adicione a página Goals
import 'package:appeducafin/views/statistics.dart'; // Adicione a página Estatísticas
import 'package:appeducafin/views/calculator.dart'; // Adicione a página Calculadora

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estatísticas'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculadora'),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}

class StatisticDashboard extends StatefulWidget {
  const StatisticDashboard({super.key});

  @override
  _StatisticDashboardState createState() => _StatisticDashboardState();
}

class _StatisticDashboardState extends State<StatisticDashboard> {
  int _currentIndex = 0; // Declare the index outside of the build method

  // Atualize a lista de páginas com referências corretas para as páginas
  final List<Widget> _pages = [
    const HomePage(), // Página Home
    //const Goals(), // Página Goals
    const StatisticDashboard(), // Página Estatísticas
    //const Calculator(), // Página Calculadora
  ];

  // Método para lidar com a seleção da aba
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Atualiza o índice da página selecionada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        backgroundColor: Colors.black,
      ),
      body: _pages[_currentIndex], // Renderiza a página baseada no índice atual
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

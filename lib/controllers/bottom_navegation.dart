import 'package:flutter/material.dart';

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
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Metas'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estatísticas'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculadora'),
      ],
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}

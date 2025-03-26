import 'package:appeducafin/views/statistic.dart';
import 'package:appeducafin/views/goals.dart';
import 'package:appeducafin/views/historical.dart';
import 'package:appeducafin/views/calculator.dart';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class HomePage extends StatelessWidget {
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
                Text('Oi, Fulana!',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                Text('Bom Dia. Bom ver você aqui.',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            CircleAvatar(
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
            SizedBox(height: 20),
            Text('Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.shield, 'Metas'),
                  _buildMenuItem(Icons.flash_on, 'Calculadora de Juros Compostos'),
                  _buildMenuItem(Icons.school, 'Conteúdo Educacional'),
                  _buildMenuItem(Icons.money, 'Renda Passiva'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estatística'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculadora'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
             break;
            // case 1:
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => Goals()),
            //   );
            //   break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvestmentDashboard()),
              );
              break;
            // case 3:
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => Calculator()),
            //   );
            //   break;
            default:
              break;
          }
        },
      ),
    );
  }

  // Definição do método _buildCard
  Widget _buildCard(String title, String amount, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(amount,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Método _buildMenuItem também está sendo usado no código
  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent),
        title: Text(title),
        tileColor: Colors.pink.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {},
      ),
    );
  }
}


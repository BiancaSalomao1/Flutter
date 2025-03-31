import 'package:flutter/material.dart';


class Report extends StatelessWidget {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvestmentReportPage();
  }
}

class InvestmentReportPage extends StatefulWidget {
  const InvestmentReportPage({super.key});

  @override
  State<InvestmentReportPage> createState() => _InvestmentReportPageState();
}

class _InvestmentReportPageState extends State<InvestmentReportPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedInvestment = 'Tesouro Direto IPCA+ 2026';
  double totalAporte = 12500.00;
  double jurosAcumulados = 2345.67;
  int tempoInvestimento = 18;

  final List<String> investmentOptions = [
    'Tesouro Direto IPCA+ 2026',
    'CDB Banco XP - 110% CDI',
    'Fundo Multimercado Vinci',
    'LCI Banco Inter - 90% CDI',
    'Fundo Imobiliário VGHF11',
    'ETF BOVA11',
  ];

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório gerado com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Relatório de Investimentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Opções de Investimento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ...investmentOptions.map((investment) {
              return ListTile(
                title: Text(investment),
                selected: investment == selectedInvestment,
                onTap: () {
                  setState(() {
                    selectedInvestment = investment;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container com imagem de estatística
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      selectedInvestment,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/investment_chart.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.insert_chart, size: 100, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Desempenho nos últimos 12 meses',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Container com resumo do investimento
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo do Investimento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Total Aportado:', totalAporte),
                  _buildSummaryItem('Juros Acumulados:', jurosAcumulados),
                  _buildSummaryItem('Tempo de Investimento:', tempoInvestimento, isCurrency: false, suffix: 'meses'),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Valor Atual:', totalAporte + jurosAcumulados),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Histórico de Aportes'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Metas e Prazos'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botão de impressão
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Gerar Relatório PDF'),
              onPressed: _printReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationController(), 
    );
  }

  Widget _buildSummaryItem(String label, dynamic value, {bool isCurrency = true, String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            isCurrency
                ? 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}'
                : '$value $suffix',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

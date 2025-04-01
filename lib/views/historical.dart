import 'package:flutter/material.dart';

class HistoricalPage extends StatelessWidget {
  const HistoricalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HistoryItem> historyList = [
      HistoryItem(month: 'OUTUBRO 2024', amount: 800, status: HistoryStatus.pending),
      HistoryItem(month: 'SETEMBRO 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'AGOSTO 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'JULHO 2024', amount: 800, status: HistoryStatus.missed),
      HistoryItem(month: 'JUNHO 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'MAIO 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'ABRIL 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'MARÇO 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'FEVEREIRO 2024', amount: 800, status: HistoryStatus.done),
      HistoryItem(month: 'JANEIRO 2024', amount: 800, status: HistoryStatus.missed),
      HistoryItem(month: 'DEZEMBRO 2023', amount: 800, status: HistoryStatus.done),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),
              _buildInvestmentSummary(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    return _buildHistoryRow(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Text('Histórico',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.print, color: Colors.black),
          onPressed: () => _showPrintDialog(context),
        ),
      ],
    );
  }

  Widget _buildInvestmentSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.show_chart, color: Colors.purple),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'CDB Banco C3\nMultimercado',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Icon(Icons.expand_more),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(HistoryItem item) {
    Color color;
    switch (item.status) {
      case HistoryStatus.done:
        color = Colors.green;
        break;
      case HistoryStatus.missed:
        color = Colors.orange;
        break;
      case HistoryStatus.pending:
        color = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.month)),
          Expanded(flex: 2, child: Text('R\$${item.amount.toStringAsFixed(2)}')),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: item.status == HistoryStatus.pending ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: color,
              ),
              child: const Text('Check'),
            ),
          ),
        ],
      ),
    );
  }

 void _showPrintDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.deepPurple.shade900,
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TODO: lógica para exportar como PDF
            },
            leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
            title: const Text(
              'SALVAR COMO PDF',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TODO: lógica para imprimir
            },
            leading: const Icon(Icons.print, color: Colors.white),
            title: const Text(
              'IMPRIMIR NA IMPRESSORA LOCAL',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// Enum para status
enum HistoryStatus { done, missed, pending }

// Modelo de item do histórico
class HistoryItem {
  final String month;
  final double amount;
  final HistoryStatus status;

  HistoryItem({
    required this.month,
    required this.amount,
    required this.status,
  });
}

import 'package:flutter/material.dart';

class HistoricalPage extends StatelessWidget {
  final String? title;
  final double? monthlyAmount;
  final int? months;

  const HistoricalPage({
    super.key,
    this.title,
    this.monthlyAmount,
    this.months,
  });

  @override
  Widget build(BuildContext context) {
    if (title == null || monthlyAmount == null || months == null) {
      return Scaffold(
        body: const Center(
          child: Text('Nenhuma meta foi adicionada ainda.'),
        ),
      );
    }

    final List<HistoryItem> historyList = List.generate(months!, (index) {
      final date = DateTime.now().subtract(Duration(days: 30 * index));
      final month = _formatMonthYear(date);
      final status = index == 0
          ? HistoryStatus.pending
          : index % 4 == 0
              ? HistoryStatus.missed
              : HistoryStatus.done;

      return HistoryItem(month: month, amount: monthlyAmount!, status: status);
    });

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
        children: [
          const Icon(Icons.show_chart, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.expand_more),
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

  String _formatMonthYear(DateTime date) {
    const months = [
      'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
      'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'
    ];
    return '${months[date.month - 1]} ${date.year}';
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

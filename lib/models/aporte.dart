class Aporte {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;

  Aporte({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'goalId': goalId,
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory Aporte.fromMap(String id, Map<String, dynamic> map) => Aporte(
    id: id,
    goalId: map['goalId'],
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date']),
  );
}

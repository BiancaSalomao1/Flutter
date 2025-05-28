class Goal {
  String? id;
  String userId;
  String title;
  double initialAmount;
  double targetAmount;
  double monthlyContribution;
  double interestRate;
  int durationMonths;
  double expectedReturn;
  DateTime createdAt;

  Goal({
    this.id,
    required this.userId,
    required this.title,
    required this.initialAmount,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.interestRate,
    required this.durationMonths,
    required this.expectedReturn,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'initialAmount': initialAmount,
    'targetAmount': targetAmount,
    'monthlyContribution': monthlyContribution,
    'interestRate': interestRate,
    'durationMonths': durationMonths,
    'expectedReturn': expectedReturn,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Goal.fromMap(String id, Map<String, dynamic> map) => Goal(
    id: id,
    userId: map['userId'],
    title: map['title'],
    initialAmount: (map['initialAmount'] as num).toDouble(),
    targetAmount: (map['targetAmount'] as num).toDouble(),
    monthlyContribution: (map['monthlyContribution'] as num).toDouble(),
    interestRate: (map['interestRate'] as num).toDouble(),
    durationMonths: map['durationMonths'],
    expectedReturn: (map['expectedReturn'] as num).toDouble(),
    createdAt: DateTime.parse(map['createdAt']),
  );

  double calculateProjection() {
    double amount = initialAmount;
    for (int i = 0; i < durationMonths; i++) {
      amount += monthlyContribution;
      amount *= (1 + interestRate / 100);
    }
    return amount;
  }
}

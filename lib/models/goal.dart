class Goal {
  final String id;
  final String userId;
  final String title;
  final double initialAmount;
  final double targetAmount;
  final double monthlyContribution;
  final double interestRate;
  final int durationMonths;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.initialAmount,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.interestRate,
    required this.durationMonths,
  });

  double calculateProjection() {
    double amount = initialAmount;
    for (int i = 0; i < durationMonths; i++) {
      amount += monthlyContribution;
      amount *= (1 + interestRate / 100);
    }
    return amount;
  }
}

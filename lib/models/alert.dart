class GoalAlert {
  final String goalId;
  final String title;
  final double monthDeposit;
  final int appliedMonths;
  final int depositedMonths;
  final int pendingMonths;
  final double estimatedAmount;
  final double passiveIncome;
  final String remainingTime;
  final double totalInvestment;
  final double totalInterest;

  GoalAlert({
    required this.goalId,
    required this.title,
    required this.monthDeposit,
    required this.appliedMonths,
    required this.depositedMonths,
    required this.pendingMonths,
    required this.estimatedAmount,
    required this.passiveIncome,
    required this.remainingTime,
    required this.totalInvestment,
    required this.totalInterest,
  });
}
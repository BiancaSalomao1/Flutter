class Report {
  final String id;
  final String goalId;
  final DateTime period;
  final double totalContributed;
  final double totalYield;

  Report({
    required this.id,
    required this.goalId,
    required this.period,
    required this.totalContributed,
    required this.totalYield,
  });
}

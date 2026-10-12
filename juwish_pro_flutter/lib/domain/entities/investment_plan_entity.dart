class InvestmentPlanEntity {
  final int id;
  final String name;
  final String description;
  final int durationDays;
  final double returnPercent;
  final double minInvestment;
  final double maxInvestment;
  final String riskProfile;
  final bool capitalReturned;
  final String sector;

  const InvestmentPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.returnPercent,
    required this.minInvestment,
    required this.maxInvestment,
    required this.riskProfile,
    required this.capitalReturned,
    this.sector = 'Crypto & DeFi',
  });
}

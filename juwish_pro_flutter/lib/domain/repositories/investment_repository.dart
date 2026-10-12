import '../entities/investment_plan_entity.dart';

abstract class InvestmentRepository {
  Future<List<InvestmentPlanEntity>> getInvestmentPlans();
  Future<bool> stakeOrInvest({
    required int planId,
    required double amount,
    required bool compounding,
  });
  Future<Map<String, dynamic>> getPortfolioSummary();
}

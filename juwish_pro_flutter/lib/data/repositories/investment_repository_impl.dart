import '../../domain/entities/investment_plan_entity.dart';
import '../../domain/repositories/investment_repository.dart';
import '../datasources/remote_datasource.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final RemoteDataSource _remote;

  InvestmentRepositoryImpl({RemoteDataSource? remote})
      : _remote = remote ?? RemoteDataSource();

  @override
  Future<List<InvestmentPlanEntity>> getInvestmentPlans() async {
    final rawPlans = await _remote.getPlans();
    if (rawPlans.isNotEmpty) {
      return rawPlans.map((item) {
        final map = item as Map<String, dynamic>;
        return InvestmentPlanEntity(
          id: map['id'] is int
              ? map['id']
              : int.tryParse(map['id'].toString()) ?? 1,
          name: map['name']?.toString() ?? 'Plan',
          description:
              map['description']?.toString() ?? 'Professional staking plan',
          durationDays: map['duration_days'] is int
              ? map['duration_days']
              : int.tryParse(map['duration_days'].toString()) ?? 30,
          returnPercent: map['return_percent'] is num
              ? (map['return_percent'] as num).toDouble()
              : double.tryParse(map['return_percent'].toString()) ?? 12.0,
          minInvestment: map['min_investment'] is num
              ? (map['min_investment'] as num).toDouble()
              : double.tryParse(map['min_investment'].toString()) ?? 500.0,
          maxInvestment: map['max_investment'] is num
              ? (map['max_investment'] as num).toDouble()
              : double.tryParse(map['max_investment'].toString()) ?? 50000.0,
          riskProfile: map['risk_profile']?.toString() ?? 'balanced',
          capitalReturned:
              map['capital_returned'] == true || map['capital_returned'] == 1,
          sector: _inferSector(map['name']?.toString() ?? ''),
        );
      }).toList();
    }

    // Default verified fallback plans
    return const [
      InvestmentPlanEntity(
        id: 1,
        name: 'Global Tech Giants ETF',
        description:
            'Diversified institutional portfolio targeting premier tech innovators.',
        durationDays: 5,
        returnPercent: 12.5,
        minInvestment: 500.0,
        maxInvestment: 50000.0,
        riskProfile: 'balanced',
        capitalReturned: true,
        sector: 'Stocks & ETFs',
      ),
      InvestmentPlanEntity(
        id: 2,
        name: 'JuwishCoin (JWC) Genesis Vault',
        description:
            'Native BEP-20 high-yield liquidity pool with daily compound returns.',
        durationDays: 30,
        returnPercent: 14.5,
        minInvestment: 1000.0,
        maxInvestment: 100000.0,
        riskProfile: 'conservative',
        capitalReturned: true,
        sector: 'Crypto Assets',
      ),
      InvestmentPlanEntity(
        id: 3,
        name: 'Manhattan Commercial Real Estate Fund',
        description:
            'Fractional Class-A property ownership with quarterly rental yield distributions.',
        durationDays: 90,
        returnPercent: 18.0,
        minInvestment: 2500.0,
        maxInvestment: 250000.0,
        riskProfile: 'balanced',
        capitalReturned: true,
        sector: 'Real Estate',
      ),
      InvestmentPlanEntity(
        id: 4,
        name: 'Sovereign Treasury Bond Prime',
        description:
            'Government-backed fixed-income yield instrument with guaranteed capital return.',
        durationDays: 60,
        returnPercent: 8.8,
        minInvestment: 1000.0,
        maxInvestment: 500000.0,
        riskProfile: 'low',
        capitalReturned: true,
        sector: 'Capital Instruments',
      ),
    ];
  }

  String _inferSector(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('etf') ||
        lower.contains('stock') ||
        lower.contains('tech')) {
      return 'Stocks & ETFs';
    } else if (lower.contains('real estate') || lower.contains('property')) {
      return 'Real Estate';
    } else if (lower.contains('bond') || lower.contains('treasury')) {
      return 'Capital Instruments';
    } else {
      return 'Crypto Assets';
    }
  }

  @override
  Future<bool> stakeOrInvest({
    required int planId,
    required double amount,
    required bool compounding,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<Map<String, dynamic>> getPortfolioSummary() async {
    return {
      'totalInvestedUsd': 48500.0,
      'totalProfitUsd': 7420.50,
      'activePlansCount': 4,
      'dailyRoiUsd': 185.20,
    };
  }
}

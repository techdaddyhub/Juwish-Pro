import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/wallet_bloc.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final WalletBloc walletBloc;

  const TransactionHistoryScreen({super.key, required this.walletBloc});

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.settled:
      case TransactionStatus.approved:
        return AppTheme.greenBullish;
      case TransactionStatus.pending:
        return AppTheme.gold;
      case TransactionStatus.rejected:
        return AppTheme.redBearish;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.tradeProfit:
        return Icons.trending_up;
      case TransactionType.stakingReward:
        return Icons.savings;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WalletState>(
      stream: walletBloc.stream,
      initialData: walletBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const WalletState();

        return Scaffold(
          backgroundColor: AppTheme.nightObsidian,
          appBar: AppBar(
            title: const Text('Real-Time Ledger & History'),
            backgroundColor: AppTheme.nightObsidian,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Filter Chips Ribbon
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    'All',
                    'deposit',
                    'withdrawal',
                    'stakingReward',
                    'tradeProfit'
                  ].map((f) {
                    final isSelected =
                        state.activeFilter.toLowerCase() == f.toLowerCase();
                    final label = f == 'All'
                        ? 'All Transactions'
                        : f == 'deposit'
                            ? 'Deposits'
                            : f == 'withdrawal'
                                ? 'Withdrawals'
                                : f == 'stakingReward'
                                    ? 'Staking Rewards'
                                    : 'Trading Profits';

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppTheme.gold,
                        backgroundColor: AppTheme.surfaceCharcoal,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.nightObsidian
                              : AppTheme.textPrimary,
                        ),
                        onSelected: (_) => walletBloc.filterTransactions(f),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Ledger List
              Expanded(
                child: state.transactions.isEmpty
                    ? const Center(
                        child: Text('No transactions found',
                            style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = state.transactions[index];
                          final isCredit = tx.type == TransactionType.deposit ||
                              tx.type == TransactionType.tradeProfit ||
                              tx.type == TransactionType.stakingReward;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCharcoal,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppTheme.borderHighlight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          _getStatusColor(tx.status)
                                              .withOpacity(0.18),
                                      child: Icon(
                                        _getTypeIcon(tx.type),
                                        size: 18,
                                        color: _getStatusColor(tx.status),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${tx.type.name.toUpperCase()} • ${tx.asset}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                                fontSize: 13),
                                          ),
                                          Text(
                                            '${tx.network} • ${tx.createdAt.toIso8601String().substring(0, 16).replaceAll("T", " ")}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${isCredit ? '+' : '-'}${tx.amount} ${tx.asset}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCredit
                                                ? AppTheme.greenBullish
                                                : AppTheme.redBearish,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          AppFormatters.formatUsd(tx.amountUsd),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.gold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(tx.status)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tx.status.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(tx.status),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(
                                            ClipboardData(text: tx.txHash));
                                        HapticFeedback.lightImpact();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Transaction Hash copied!'),
                                              backgroundColor:
                                                  AppTheme.greenBullish),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'Tx: ${AppFormatters.formatAddress(tx.txHash)}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.copy,
                                              size: 12, color: AppTheme.gold),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

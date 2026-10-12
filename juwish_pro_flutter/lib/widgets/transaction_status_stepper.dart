import 'package:flutter/material.dart';
import '../models/checkout_order.dart';

/// JuwishPro - Blockchain Transaction Progress Stepper
class TransactionStatusStepper extends StatelessWidget {
  final PaymentStatus status;
  final int currentConfirmations;
  final int requiredConfirmations;
  final String? txHash;

  const TransactionStatusStepper({
    super.key,
    required this.status,
    required this.currentConfirmations,
    this.requiredConfirmations = 15,
    this.txHash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C3242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 18, color: Color(0xFF3888FF)),
              const SizedBox(width: 8),
              const Text(
                'BNB Smart Chain Settlement Status',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepNode(
                stepIndex: 1,
                title: 'Broadcast',
                isActive: status != PaymentStatus.idle,
                isCompleted: status == PaymentStatus.txDetected ||
                    status == PaymentStatus.confirming ||
                    status == PaymentStatus.confirmed,
              ),
              _buildStepConnector(
                isCompleted: status == PaymentStatus.confirming || status == PaymentStatus.confirmed,
              ),
              _buildStepNode(
                stepIndex: 2,
                title: 'Confirming',
                subtitle: status == PaymentStatus.confirming
                    ? '$currentConfirmations/$requiredConfirmations blocks'
                    : null,
                isActive: status == PaymentStatus.confirming,
                isCompleted: status == PaymentStatus.confirmed,
              ),
              _buildStepConnector(
                isCompleted: status == PaymentStatus.confirmed,
              ),
              _buildStepNode(
                stepIndex: 3,
                title: 'Unlocked',
                isActive: status == PaymentStatus.confirmed,
                isCompleted: status == PaymentStatus.confirmed,
              ),
            ],
          ),
          if (txHash != null && txHash!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF14171F),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF2C3242)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 14, color: Color(0xFFF0B90B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tx: $txHash',
                      style: const TextStyle(
                        color: Color(0xFF848E9C),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (status) {
      case PaymentStatus.confirmed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1B4332),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF2D6A4F)),
          ),
          child: const Text(
            'CONFIRMED (15/15)',
            style: TextStyle(color: Color(0xFF52B788), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      case PaymentStatus.confirming:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFF8F00)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFB300)),
              ),
              const SizedBox(width: 6),
              Text(
                'CONFIRMING ($currentConfirmations/$requiredConfirmations)',
                style: const TextStyle(color: Color(0xFFFFB300), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case PaymentStatus.txDetected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'TX DETECTED',
            style: TextStyle(color: Color(0xFF64B5F6), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF262C38),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'AWAITING TRANSFER',
            style: TextStyle(color: Color(0xFF8F9BB3), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  Widget _buildStepNode({
    required int stepIndex,
    required String title,
    String? subtitle,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color nodeColor = const Color(0xFF2C3242);
    Color textColor = const Color(0xFF8F9BB3);

    if (isCompleted) {
      nodeColor = const Color(0xFF2ECC71);
      textColor = Colors.white;
    } else if (isActive) {
      nodeColor = const Color(0xFF3888FF);
      textColor = const Color(0xFF3888FF);
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted ? nodeColor : const Color(0xFF151821),
            shape: BoxShape.circle,
            border: Border.all(color: nodeColor, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : Text(
                    '$stepIndex',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFFFB300),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22, left: 8, right: 8),
        color: isCompleted ? const Color(0xFF2ECC71) : const Color(0xFF2C3242),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balanceBtc,
    this.label = 'Total balance',
    this.isLoading = false,
    this.hideBalance = false,
  });

  final double balanceBtc;
  final String label;
  final bool isLoading;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final formattedBalance = balanceBtc.toStringAsFixed(8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            SizedBox(
              height: 38,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            )
          else
            Text(
              hideBalance ? '••••••••' : '$formattedBalance BTC',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 27,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Bitcoin • Testnet',
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

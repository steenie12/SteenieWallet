import 'package:flutter/material.dart';

import '../../widgets/wallet_balance_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.currency_bitcoin, color: Color(0xFFF7931A)),
            SizedBox(width: 8),
            Text('VELARIO WALLET'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings are not connected yet.')),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your wallet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            const Text('Bitcoin testnet · Development build'),
            const SizedBox(height: 22),
            const WalletBalanceCard(
              balanceBtc: 0,
              label: 'Testnet balance',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.south_west,
                    label: 'Receive',
                    onPressed: () => _showNotReady(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.north_east,
                    label: 'Send',
                    onPressed: () => _showNotReady(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Recent activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D22),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 38,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No transactions to show',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your testnet activity will appear here after the '
                    'blockchain connection is implemented.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Testnet only. Do not deposit real Bitcoin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }

  static void _showNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This feature is not enabled until wallet security is completed.',
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

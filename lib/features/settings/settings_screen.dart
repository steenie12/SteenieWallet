import 'package:flutter/material.dart';

import '../../core/constants/network_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.currency_bitcoin),
                    title: const Text('Blockchain'),
                    subtitle: const Text('Bitcoin'),
                    trailing: const Icon(Icons.check_circle_outline),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.hub_outlined),
                    title: const Text('Network'),
                    subtitle: Text(
                      NetworkConstants.nameFor(
                        NetworkConstants.initialNetwork,
                      ),
                    ),
                    trailing: const Chip(label: Text('Testnet')),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.language_outlined),
                    title: Text('Blockchain data provider'),
                    subtitle: Text('Blockstream Esplora API'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Security',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('Biometric unlock'),
                    subtitle: const Text(
                      'Device authentication integration is pending.',
                    ),
                    trailing: const Icon(Icons.lock_outline),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Wallet PIN'),
                    subtitle: const Text(
                      'Secure PIN setup is not implemented yet.',
                    ),
                    trailing: const Icon(Icons.lock_outline),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.key_outlined),
                    title: const Text('Recovery phrase'),
                    subtitle: const Text(
                      'Encrypted persistence and recovery verification '
                      'are not connected yet.',
                    ),
                    trailing: const Icon(Icons.warning_amber_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined),
                    title: Text('Steenie Wallet'),
                    subtitle: Text('Version 0.1.0 · Development'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.code_outlined),
                    title: Text('Open-source project'),
                    subtitle: Text(
                      'Designed for transparent, self-custody wallet '
                      'development.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This build is for development and testnet use only. '
              'It has not been audited and must not hold real funds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}

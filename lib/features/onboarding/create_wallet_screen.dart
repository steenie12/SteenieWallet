import 'package:flutter/material.dart';

import '../../wallet/wallet_service.dart';
import '../../widgets/security_warning.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final WalletService _walletService = WalletService();

  String? _phrase;
  bool _confirmedWrittenDown = false;

  void _createPhrase() {
    // Generate only after the user explicitly taps the button.
    // Never print this value to logs or send it to a server.
    final phrase = _walletService.createRecoveryPhrase();

    setState(() {
      _phrase = phrase;
      _confirmedWrittenDown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = _phrase?.split(' ') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steenie Wallet'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 58,
              color: Color(0xFFF7931A),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Bitcoin. Your keys.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create a self-custody wallet. Your recovery phrase gives '
              'you control of your funds, so protect it carefully.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            const SecurityWarning(),
            const SizedBox(height: 24),
            if (_phrase == null) ...[
              const Text(
                'Start with Bitcoin testnet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Testnet coins are for testing and have no intended '
                'monetary value. This app is still being built.',
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _createPhrase,
                icon: const Icon(Icons.add_moderator_outlined),
                label: const Text('Create recovery phrase'),
              ),
            ] else ...[
              const Text(
                'Your 12-word recovery phrase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Write these words down in order. Do not take a screenshot, '
                'upload them, or share them with anyone.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1D22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: words.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}. ${words[index]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _confirmedWrittenDown,
                onChanged: (value) {
                  setState(() {
                    _confirmedWrittenDown = value ?? false;
                  });
                },
                title: const Text('I have written down my recovery phrase'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _confirmedWrittenDown
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Phrase acknowledged. Secure storage and '
                              'recovery verification are not connected yet.',
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _phrase = null;
                    _confirmedWrittenDown = false;
                  });
                },
                child: const Text('Discard phrase from this screen'),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Development build only. Do not use this app to store or '
              'send real funds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}

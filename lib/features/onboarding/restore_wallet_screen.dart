import 'package:flutter/material.dart';

import '../../wallet/wallet_service.dart';
import '../../widgets/security_warning.dart';

class RestoreWalletScreen extends StatefulWidget {
  const RestoreWalletScreen({super.key});

  @override
  State<RestoreWalletScreen> createState() => _RestoreWalletScreenState();
}

class _RestoreWalletScreenState extends State<RestoreWalletScreen> {
  final TextEditingController _phraseController = TextEditingController();
  final WalletService _walletService = WalletService();

  bool _isValid = false;
  bool _hasChecked = false;

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  void _validatePhrase() {
    // Keep the phrase in memory only. Never log or upload it.
    final valid = _walletService.validateRecoveryPhrase(
      _phraseController.text,
    );

    setState(() {
      _isValid = valid;
      _hasChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore wallet'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text(
              'Restore your wallet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your recovery words in the correct order. '
              'Validation checks the BIP39 format and checksum only.',
            ),
            const SizedBox(height: 20),
            const SecurityWarning(
              title: 'Keep your phrase private',
              message:
                  'Enter it only into a wallet you trust. Never send it '
                  'to support staff, websites, or other people.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phraseController,
              minLines: 3,
              maxLines: 5,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'Recovery phrase',
                hintText: 'Enter your 12 words separated by spaces',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _validatePhrase,
              child: const Text('Validate recovery phrase'),
            ),
            if (_hasChecked) ...[
              const SizedBox(height: 16),
              Text(
                _isValid
                    ? 'The phrase has a valid BIP39 checksum.'
                    : 'The phrase is invalid. Check the words and their order.',
                style: TextStyle(
                  color: _isValid ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isValid) ...[
                const SizedBox(height: 10),
                const Text(
                  'This is not a complete restoration yet. The phrase has '
                  'not been saved, and no Bitcoin address has been derived.',
                ),
              ],
            ],
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                _phraseController.clear();
                setState(() {
                  _isValid = false;
                  _hasChecked = false;
                });
              },
              child: const Text('Clear phrase'),
            ),
          ],
        ),
      ),
    );
  }
}

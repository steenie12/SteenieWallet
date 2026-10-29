import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({
    super.key,
    this.address,
  });

  final String? address;

  @override
  Widget build(BuildContext context) {
    final receiveAddress = address?.trim() ?? '';
    final hasValidAddress = receiveAddress.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Bitcoin'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Icon(
              Icons.south_west_rounded,
              size: 44,
              color: Color(0xFFF7931A),
            ),
            const SizedBox(height: 16),
            Text(
              'Receive Bitcoin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Always verify the network and address before sending funds.',
            ),
            const SizedBox(height: 24),
            if (hasValidAddress) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: receiveAddress,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Your receiving address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                receiveAddress,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Copy support will be connected in a later step.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy address'),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1D22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 48,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No verified address yet',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create or restore a wallet and complete address '
                      'derivation before receiving testnet Bitcoin.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Development build — do not use for real funds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}

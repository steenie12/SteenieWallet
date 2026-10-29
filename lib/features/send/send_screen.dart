import 'package:flutter/material.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();

  String _feeLevel = 'Standard';

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _reviewTransaction() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaction signing is not implemented. No transaction was sent.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Bitcoin'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                'Send Bitcoin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Testnet only. Check every transaction detail carefully.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _addressController,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Recipient address',
                  hintText: 'Enter a Bitcoin testnet address',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a recipient address.';
                  }
                  if (value.trim().length < 14) {
                    return 'The address looks too short.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount in BTC',
                  hintText: '0.00000000',
                  prefixIcon: Icon(Icons.currency_bitcoin),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter an amount greater than zero.';
                  }

                  if (amount > 21000000) {
                    return 'Amount exceeds the maximum BTC supply.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Network fee',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _feeLevel,
                decoration: const InputDecoration(
                  labelText: 'Fee priority',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Economy',
                    child: Text('Economy'),
                  ),
                  DropdownMenuItem(
                    value: 'Standard',
                    child: Text('Standard'),
                  ),
                  DropdownMenuItem(
                    value: 'Priority',
                    child: Text('Priority'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _feeLevel = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _reviewTransaction,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Review transaction'),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sending is disabled while local signing and transaction '
                'verification are being developed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

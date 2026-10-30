import 'package:flutter/material.dart';

import '../../wallet/wallet_vault_service.dart';

class UnlockWalletScreen extends StatefulWidget {
  const UnlockWalletScreen({
    super.key,
    required this.onUnlocked,
    this.onImport,
  });

  final ValueChanged<WalletVault> onUnlocked;
  final VoidCallback? onImport;

  @override
  State<UnlockWalletScreen> createState() => _UnlockWalletScreenState();
}

class _UnlockWalletScreenState extends State<UnlockWalletScreen> {
  final _passwordController = TextEditingController();
  final _vaultService = WalletVaultService();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_loading) return;

    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _error = 'Enter your wallet password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final vault = await _vaultService.unlockWallet(password: password);

      if (!mounted) return;

      _passwordController.clear();
      widget.onUnlocked(vault);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to unlock. Check your password or wallet data.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 38,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'VELARIO WALLET',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your wallet. Your keys. Your control.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    onSubmitted: (_) => _unlock(),
                    decoration: InputDecoration(
                      labelText: 'Wallet password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _unlock,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Unlock wallet'),
                    ),
                  ),
                  if (widget.onImport != null) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: widget.onImport,
                      child: const Text('Import another wallet'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Your encrypted wallet stays on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

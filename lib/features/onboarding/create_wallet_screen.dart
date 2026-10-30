import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/coins/coin_registry.dart';

import '../../core/security/wallet_crypto.dart';
import '../../storage/secure_wallet_storage.dart';
import '../../wallet/wallet_service.dart';
import '../../widgets/security_warning.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final WalletService _walletService = WalletService();
  final WalletCrypto _crypto = WalletCrypto();
  final SecureWalletStorage _storage = SecureWalletStorage();

  final List<TextEditingController> _wordControllers =
      List.generate(3, (_) => TextEditingController());

  String? _phrase;
  List<int> _challengeIndexes = [];
  bool _confirmedWrittenDown = false;
  bool _showVerification = false;
  bool _saving = false;
  bool _checkingStorage = true;
  bool _existingWallet = false;
  bool _walletSaved = false;

  @override
  void initState() {
    super.initState();
    _checkExistingWallet();
  }

  Future<void> _checkExistingWallet() async {
    try {
      final exists = await _storage.hasWallet();
      if (!mounted) return;
      setState(() {
        _existingWallet = exists;
        _checkingStorage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingStorage = false);
      _showMessage(
        'Could not check secure storage. Do not create a wallet yet.',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _wordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _createPhrase() {
    final phrase = _walletService.createRecoveryPhrase();
    final random = Random.secure();
    final indexes = <int>{};

    while (indexes.length < 3) {
      indexes.add(random.nextInt(12));
    }

    for (final controller in _wordControllers) {
      controller.clear();
    }

    setState(() {
      _phrase = phrase;
      _challengeIndexes = indexes.toList()..sort();
      _confirmedWrittenDown = false;
      _showVerification = false;
    });
  }

  Future<String?> _askForPassword() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Protect your wallet'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create a password of at least 12 characters. '
                  'You will need it to unlock the encrypted wallet. '
                  'It cannot be recovered if you forget it.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Wallet password',
                  ),
                  validator: (value) {
                    if (value == null || value.length < 12) {
                      return 'Use at least 12 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, passwordController.text);
              }
            },
            child: const Text('Encrypt wallet'),
          ),
        ],
      ),
    );

    passwordController.dispose();
    confirmController.dispose();
    return result;
  }

  Future<void> _verifyAndSave() async {
    final phrase = _phrase;
    if (phrase == null || _saving) return;

    final words = phrase.split(' ');

    for (var i = 0; i < _challengeIndexes.length; i++) {
      final answer = _wordControllers[i].text.trim().toLowerCase();
      final expected = words[_challengeIndexes[i]].toLowerCase();

      if (answer != expected) {
        _showMessage(
          'Word ${_challengeIndexes[i] + 1} is incorrect. Check your '
          'written recovery phrase and try again.',
        );
        return;
      }
    }

    final password = await _askForPassword();
    if (!mounted || password == null) return;

    setState(() => _saving = true);

    try {
      // Only the encrypted JSON payload is written to secure storage.
      final walletData = jsonEncode({
        'version': 1,
        'network': 'bitcoin-testnet',
        'mnemonic': phrase,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      final encryptedPayload = await _crypto.encrypt(
        plaintext: walletData,
        password: password,
      );

      // Recheck before writing to avoid intentionally replacing a wallet.
      if (await _storage.hasWallet()) {
        if (!mounted) return;
        setState(() => _existingWallet = true);
        _showMessage(
          'A wallet already exists. No existing wallet was replaced.',
        );
        return;
      }

      await _storage.saveEncryptedWallet(encryptedPayload);

      if (!mounted) return;
      setState(() {
        _walletSaved = true;
        _phrase = null;
        _showVerification = false;
        _existingWallet = true;
      });

      _showMessage('Recovery words verified and encrypted wallet saved.');
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Wallet was not saved. Check device storage and try again. '
          'Keep your written recovery phrase safe.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _phrase?.split(' ') ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('VELARIO WALLET')),
      body: SafeArea(
        child: _checkingStorage
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const Icon(
                    Icons.shield_lock_outlined,
                    size: 64,
                    color: Color(0xFF42DDB2),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Your keys. Your control.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kakushi is being developed as a self-custody wallet. '
                    'Your recovery phrase is highly sensitive.',
                  ),
                  const SizedBox(height: 22),
                  const SecurityWarning(),
                  const SizedBox(height: 24),

                  if (_existingWallet || _walletSaved) ...[
                    const Icon(
                      Icons.lock_outline,
                      size: 42,
                      color: Color(0xFF42DDB2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _walletSaved
                          ? 'Wallet encrypted on this device'
                          : 'An encrypted wallet already exists',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This screen does not yet unlock an existing wallet '
                      'or restore one from a recovery phrase. Do not clear '
                      'app data or uninstall the app expecting local data '
                      'to remain. Keep your written recovery phrase safe.',
                    ),
                  ] else if (_phrase == null) ...[
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
                      icon: const Icon(Icons.shield_outlined),
                      label: const Text('Create recovery phrase'),
                    ),
                  ] else if (!_showVerification) ...[
                    const Text(
                      'Your 12-word recovery phrase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Write these words on paper in the correct order. '
                      'Never screenshot, upload, or share them.',
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
                        itemBuilder: (context, index) => Container(
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _confirmedWrittenDown,
                      onChanged: (value) {
                        setState(
                          () => _confirmedWrittenDown = value ?? false,
                        );
                      },
                      title: const Text(
                        'I have written down my recovery phrase',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: _confirmedWrittenDown
                          ? () => setState(() => _showVerification = true)
                          : null,
                      child: const Text('Verify recovery phrase'),
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
                  ] else ...[
                    const Text(
                      'Confirm your recovery phrase',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the words at the requested positions from '
                      'the phrase you wrote down.',
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _challengeIndexes.length; i++) ...[
                      TextFormField(
                        controller: _wordControllers[i],
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.none,
                        decoration: InputDecoration(
                          labelText: 'Word ${_challengeIndexes[i] + 1}',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed: _saving ? null : _verifyAndSave,
                      child: Text(
                        _saving ? 'Encrypting wallet…' : 'Verify and encrypt',
                      ),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _showVerification = false),
                      child: const Text('Back to recovery phrase'),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Multi-coin roadmap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'These networks are listed for development. '
                    'Sending and receiving are not enabled for every coin.',
                  ),
                  const SizedBox(height: 12),
                  ...CoinRegistry.all.map((coin) {
                    final status = switch (coin.status) {
                      CoinSupportStatus.foundationOnly => 'Foundation only',
                      CoinSupportStatus.inDevelopment => 'In development',
                      CoinSupportStatus.planned => 'Planned',
                    };

                    final networkNames = coin.networks
                        .map((network) => network.name)
                        .join(' · ');

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF183B35),
                          child: Text(
                            coin.symbol,
                            style: const TextStyle(
                              color: Color(0xFF75F0CA),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(coin.name),
                        subtitle: Text('$networkNames\\n$status'),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.schedule,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    'Development build only. Do not use this app to store '
                    'or send real funds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                ],
              ),
      ),
    );
  }
}

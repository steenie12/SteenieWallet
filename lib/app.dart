import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/onboarding/create_wallet_screen.dart';
import 'features/onboarding/unlock_wallet_screen.dart';
import 'wallet/wallet_vault_service.dart';

class SteenieWalletApp extends StatelessWidget {
  const SteenieWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF7931A);
    const background = Color(0xFF101114);

    return MaterialApp(
      title: 'VELARIO WALLET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1C1D22),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1D22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const WalletEntryGate(),
    );
  }
}

class WalletEntryGate extends StatefulWidget {
  const WalletEntryGate({super.key});

  @override
  State<WalletEntryGate> createState() => _WalletEntryGateState();
}

class _WalletEntryGateState extends State<WalletEntryGate> {
  final WalletVaultService _vault = WalletVaultService();
  bool? _hasWallet;

  @override
  void initState() {
    super.initState();
    _checkWallet();
  }

  Future<void> _checkWallet() async {
    try {
      final exists = await _vault.hasWallet();
      if (!mounted) return;
      setState(() => _hasWallet = exists);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasWallet = false);
    }
  }

  void _enterWallet(WalletVault vault) {
    if (!mounted) return;
    setState(() => _hasWallet = true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(vault: vault),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasWallet == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasWallet == true) {
      return UnlockWalletScreen(
        onUnlocked: _enterWallet,
        onImport: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Wallet import screen is the next upgrade.',
              ),
            ),
          );
        },
      );
    }

    return CreateWalletScreen(onWalletReady: _enterWallet);
  }
}

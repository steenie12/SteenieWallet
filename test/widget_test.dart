import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/app.dart';
import 'package:steenie_wallet/features/onboarding/create_wallet_screen.dart';
import 'package:steenie_wallet/wallet/wallet_vault_service.dart';

class _FakeWalletVaultService extends WalletVaultService {
  @override
  Future<bool> hasWallet() async => false;
}

void main() {
  testWidgets(
    'Wallet entry gate opens creation screen when no wallet exists',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WalletEntryGate(
            vaultService: _FakeWalletVaultService(),
          ),
        ),
      );

      // Allow the asynchronous wallet check to finish.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CreateWalletScreen), findsOneWidget);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/app.dart';
import 'package:steenie_wallet/features/onboarding/create_wallet_screen.dart';

void main() {
  testWidgets('SteenieWallet opens the wallet creation screen', (
    tester,
  ) async {
    await tester.pumpWidget(const SteenieWalletApp());
    await tester.pump();

    expect(find.byType(SteenieWalletApp), findsOneWidget);
    expect(find.byType(CreateWalletScreen), findsOneWidget);
  });
}

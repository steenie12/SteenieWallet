import 'package:flutter_test/flutter_test.dart';
import 'package:steenie_wallet/app.dart';

void main() {
  testWidgets('SteenieWallet app starts', (tester) async {
    await tester.pumpWidget(const SteenieWalletApp());

    expect(find.text('SteenieWallet'), findsWidgets);
  });
}

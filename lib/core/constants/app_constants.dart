class AppConstants {
  AppConstants._();

  static const String appName = 'Steenie Wallet';
  static const String appVersion = '0.1.0';
  static const int buildNumber = 1;

  static const String primaryCurrency = 'BTC';
  static const String smallestBitcoinUnit = 'sats';

  /// One bitcoin contains 100 million satoshis.
  static const int satoshisPerBitcoin = 100000000;

  /// Bitcoin's protocol maximum supply, expressed in BTC.
  static const int maximumBitcoinSupply = 21000000;

  /// This project is still under development.
  static const bool isDevelopmentBuild = true;

  /// Keep real-money spending disabled during development.
  static const bool allowMainnetSpending = false;

  static const String developmentNotice =
      'Development build only. Do not use with real funds.';
}

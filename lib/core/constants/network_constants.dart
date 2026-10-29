enum BitcoinNetwork {
  testnet,
  mainnet,
}

class NetworkConstants {
  NetworkConstants._();

  static const BitcoinNetwork initialNetwork = BitcoinNetwork.testnet;

  static const String testnetName = 'Bitcoin Testnet';
  static const String mainnetName = 'Bitcoin Mainnet';

  // Public Esplora API endpoints. These receive public wallet addresses
  // and transaction queries, never seed phrases or private keys.
  static const String testnetApi =
      'https://blockstream.info/testnet/api';

  static const String mainnetApi =
      'https://blockstream.info/api';

  static String apiFor(BitcoinNetwork network) {
    switch (network) {
      case BitcoinNetwork.testnet:
        return testnetApi;
      case BitcoinNetwork.mainnet:
        return mainnetApi;
    }
  }

  static String nameFor(BitcoinNetwork network) {
    switch (network) {
      case BitcoinNetwork.testnet:
        return testnetName;
      case BitcoinNetwork.mainnet:
        return mainnetName;
    }
  }

  static String addressPrefixFor(BitcoinNetwork network) {
    switch (network) {
      case BitcoinNetwork.testnet:
        return 'tb1';
      case BitcoinNetwork.mainnet:
        return 'bc1';
    }
  }
}

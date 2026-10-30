enum CoinSupportStatus {
  foundationOnly,
  inDevelopment,
  planned,
}

class CoinNetwork {
  const CoinNetwork({
    required this.id,
    required this.name,
    required this.chainId,
    required this.isTestnet,
  });

  final String id;
  final String name;
  final int? chainId;
  final bool isTestnet;
}

class CoinDefinition {
  const CoinDefinition({
    required this.id,
    required this.name,
    required this.symbol,
    required this.family,
    required this.status,
    required this.networks,
  });

  final String id;
  final String name;
  final String symbol;
  final String family;
  final CoinSupportStatus status;
  final List<CoinNetwork> networks;

  // Metadata registration does not mean transaction support.
  bool get transactionsEnabled => false;
}

class CoinRegistry {
  CoinRegistry._();

  static const List<CoinDefinition> all = [
    // BITCOIN FAMILY
    CoinDefinition(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      family: 'bitcoin',
      status: CoinSupportStatus.foundationOnly,
      networks: [
        CoinNetwork(
          id: 'bitcoin-testnet',
          name: 'Bitcoin Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'litecoin',
      name: 'Litecoin',
      symbol: 'LTC',
      family: 'utxo',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'litecoin-testnet',
          name: 'Litecoin Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'dogecoin',
      name: 'Dogecoin',
      symbol: 'DOGE',
      family: 'utxo',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'dogecoin-testnet',
          name: 'Dogecoin Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'bitcoin-cash',
      name: 'Bitcoin Cash',
      symbol: 'BCH',
      family: 'utxo',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'bitcoin-cash-testnet',
          name: 'Bitcoin Cash Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // EVM FAMILY
    CoinDefinition(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'ETH',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'ethereum-sepolia',
          name: 'Ethereum Sepolia',
          chainId: 11155111,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'bnb',
      name: 'BNB Chain',
      symbol: 'BNB',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'bsc-testnet',
          name: 'BNB Smart Chain Testnet',
          chainId: 97,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'polygon',
      name: 'Polygon',
      symbol: 'POL',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'polygon-amoy',
          name: 'Polygon Amoy',
          chainId: 80002,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'base',
      name: 'Base',
      symbol: 'ETH',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'base-sepolia',
          name: 'Base Sepolia',
          chainId: 84532,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'arbitrum',
      name: 'Arbitrum',
      symbol: 'ETH',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'arbitrum-sepolia',
          name: 'Arbitrum Sepolia',
          chainId: 421614,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'optimism',
      name: 'Optimism',
      symbol: 'ETH',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'optimism-sepolia',
          name: 'Optimism Sepolia',
          chainId: 11155420,
          isTestnet: true,
        ),
      ],
    ),
    CoinDefinition(
      id: 'avalanche',
      name: 'Avalanche',
      symbol: 'AVAX',
      family: 'evm',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'avalanche-fuji',
          name: 'Avalanche Fuji',
          chainId: 43113,
          isTestnet: true,
        ),
      ],
    ),

    // SOLANA
    CoinDefinition(
      id: 'solana',
      name: 'Solana',
      symbol: 'SOL',
      family: 'solana',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'solana-devnet',
          name: 'Solana Devnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // XRP
    CoinDefinition(
      id: 'xrp',
      name: 'XRP Ledger',
      symbol: 'XRP',
      family: 'xrp',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'xrp-testnet',
          name: 'XRP Ledger Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // CARDANO
    CoinDefinition(
      id: 'cardano',
      name: 'Cardano',
      symbol: 'ADA',
      family: 'cardano',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'cardano-preprod',
          name: 'Cardano Preprod',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // POLKADOT
    CoinDefinition(
      id: 'polkadot',
      name: 'Polkadot',
      symbol: 'DOT',
      family: 'substrate',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'polkadot-westend',
          name: 'Polkadot Westend',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // TRON
    CoinDefinition(
      id: 'tron',
      name: 'TRON',
      symbol: 'TRX',
      family: 'tron',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'tron-nile',
          name: 'TRON Nile Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // COSMOS
    CoinDefinition(
      id: 'cosmos',
      name: 'Cosmos Hub',
      symbol: 'ATOM',
      family: 'cosmos',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'cosmos-testnet',
          name: 'Cosmos Hub Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // STELLAR
    CoinDefinition(
      id: 'stellar',
      name: 'Stellar',
      symbol: 'XLM',
      family: 'stellar',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'stellar-testnet',
          name: 'Stellar Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // TON
    CoinDefinition(
      id: 'ton',
      name: 'TON',
      symbol: 'TON',
      family: 'ton',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'ton-testnet',
          name: 'TON Testnet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // MONERO
    CoinDefinition(
      id: 'monero',
      name: 'Monero',
      symbol: 'XMR',
      family: 'monero',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'monero-stagenet',
          name: 'Monero Stagenet',
          chainId: null,
          isTestnet: true,
        ),
      ],
    ),

    // CHAINLINK (EVM TOKEN, NOT A SEPARATE BLOCKCHAIN)
    CoinDefinition(
      id: 'chainlink',
      name: 'Chainlink',
      symbol: 'LINK',
      family: 'evm-token',
      status: CoinSupportStatus.planned,
      networks: [
        CoinNetwork(
          id: 'chainlink-sepolia',
          name: 'Chainlink on Ethereum Sepolia',
          chainId: 11155111,
          isTestnet: true,
        ),
      ],
    ),

    // DOGECOIN-RELATED ADDITIONAL ASSETS CAN BE ADDED
    // THROUGH THE TOKEN REGISTRY IN A FUTURE UPGRADE.
  ];

  static CoinDefinition? findById(String id) {
    for (final coin in all) {
      if (coin.id == id) return coin;
    }
    return null;
  }

  static CoinNetwork? findNetwork(String id) {
    for (final coin in all) {
      for (final network in coin.networks) {
        if (network.id == id) return network;
      }
    }
    return null;
  }

  static List<CoinDefinition> get evmCoins =>
      all.where((coin) =>
          coin.family == 'evm' || coin.family == 'evm-token').toList();

  static List<CoinDefinition> get testnetCoins =>
      all.where((coin) =>
          coin.networks.any((network) => network.isTestnet)).toList();

  static List<CoinDefinition> get coinsInDevelopment =>
      all.where((coin) =>
          coin.status == CoinSupportStatus.inDevelopment).toList();
}

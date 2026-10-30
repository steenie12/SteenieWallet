import '../core/constants/network_constants.dart';

class WalletAccount {
  final String id;
  final String name;
  final String address;

  // Retained for compatibility with existing Bitcoin accounts.
  final BitcoinNetwork? network;

  // Network-independent account metadata.
  final String? networkId;
  final String chainFamily;
  final String symbol;
  final String derivationPath;
  final int? chainId;

  final int accountIndex;
  final int addressIndex;

  const WalletAccount({
    required this.id,
    required this.name,
    required this.address,
    this.network,
    this.networkId,
    this.chainFamily = 'bitcoin',
    this.symbol = 'BTC',
    this.derivationPath = '',
    this.chainId,
    this.accountIndex = 0,
    this.addressIndex = 0,
  });

  String get networkName {
    if (network != null) {
      return NetworkConstants.nameFor(network!);
    }
    return networkId ?? 'Unknown network';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'network': network?.name,
      'networkId': networkId,
      'chainFamily': chainFamily,
      'symbol': symbol,
      'derivationPath': derivationPath,
      'chainId': chainId,
      'accountIndex': accountIndex,
      'addressIndex': addressIndex,
    };
  }

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    final networkName = json['network'] as String?;

    BitcoinNetwork? bitcoinNetwork;
    for (final value in BitcoinNetwork.values) {
      if (value.name == networkName) {
        bitcoinNetwork = value;
        break;
      }
    }

    return WalletAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      network: bitcoinNetwork,
      networkId: json['networkId'] as String?,
      chainFamily: json['chainFamily'] as String? ?? 'bitcoin',
      symbol: json['symbol'] as String? ?? 'BTC',
      derivationPath: json['derivationPath'] as String? ?? '',
      chainId: json['chainId'] as int?,
      accountIndex: json['accountIndex'] as int? ?? 0,
      addressIndex: json['addressIndex'] as int? ?? 0,
    );
  }
}

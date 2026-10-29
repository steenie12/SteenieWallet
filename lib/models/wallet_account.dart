import '../core/constants/network_constants.dart';

class WalletAccount {
  final String id;
  final String name;
  final String address;
  final BitcoinNetwork network;
  final int accountIndex;
  final int addressIndex;

  const WalletAccount({
    required this.id,
    required this.name,
    required this.address,
    required this.network,
    this.accountIndex = 0,
    this.addressIndex = 0,
  });

  String get networkName => NetworkConstants.nameFor(network);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'network': network.name,
      'accountIndex': accountIndex,
      'addressIndex': addressIndex,
    };
  }

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    final networkName = json['network'] as String?;

    final network = BitcoinNetwork.values.firstWhere(
      (value) => value.name == networkName,
      orElse: () => BitcoinNetwork.testnet,
    );

    return WalletAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      network: network,
      accountIndex: json['accountIndex'] as int? ?? 0,
      addressIndex: json['addressIndex'] as int? ?? 0,
    );
  }
}

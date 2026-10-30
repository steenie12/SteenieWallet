import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class EvmMainnetNetwork {
  const EvmMainnetNetwork({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
    required this.rpcUrl,
  });

  final String id;
  final String name;
  final String symbol;
  final int chainId;
  final String rpcUrl;

  static const ethereum = EvmMainnetNetwork(
    id: 'ethereum',
    name: 'Ethereum',
    symbol: 'ETH',
    chainId: 1,
    rpcUrl: 'https://ethereum-rpc.publicnode.com',
  );

  static const bnb = EvmMainnetNetwork(
    id: 'bnb',
    name: 'BNB Smart Chain',
    symbol: 'BNB',
    chainId: 56,
    rpcUrl: 'https://bsc-rpc.publicnode.com',
  );

  static const polygon = EvmMainnetNetwork(
    id: 'polygon',
    name: 'Polygon',
    symbol: 'POL',
    chainId: 137,
    rpcUrl: 'https://polygon-bor-rpc.publicnode.com',
  );

  static const base = EvmMainnetNetwork(
    id: 'base',
    name: 'Base',
    symbol: 'ETH',
    chainId: 8453,
    rpcUrl: 'https://base-rpc.publicnode.com',
  );

  static const all = [
    ethereum,
    bnb,
    polygon,
    base,
  ];
}

class EvmNativeBalance {
  const EvmNativeBalance({
    required this.network,
    required this.address,
    required this.rawBalance,
  });

  final EvmMainnetNetwork network;
  final String address;
  final BigInt rawBalance;

  // EVM native currencies use 18 decimal places.
  String get amount {
    final digits = rawBalance.toString().padLeft(19, '0');
    final whole = digits.substring(0, digits.length - 18);
    final fraction = digits.substring(digits.length - 18);
    final trimmed = fraction.replaceFirst(RegExp(r'0+$'), '');

    return trimmed.isEmpty ? whole : '$whole.$trimmed';
  }

  String get displayAmount => '$amount ${network.symbol}';
}

class EvmMainnetService {
  EvmMainnetService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> _rpc(
    EvmMainnetNetwork network,
    String method,
    List<dynamic> params,
  ) async {
    final response = await _client
        .post(
          Uri.parse(network.rpcUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': method,
            'params': params,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        '${network.name} RPC returned HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid blockchain RPC response.');
    }

    if (decoded['error'] != null) {
      throw Exception('Blockchain RPC error: ${decoded['error']}');
    }

    if (!decoded.containsKey('result')) {
      throw const FormatException('Missing RPC result.');
    }

    return decoded['result'];
  }

  Future<EvmNativeBalance> fetchNativeBalance({
    required EvmMainnetNetwork network,
    required String address,
  }) async {
    final normalizedAddress = address.trim();

    if (!RegExp(r'^0x[a-fA-F0-9]{40}$')
        .hasMatch(normalizedAddress)) {
      throw ArgumentError('Invalid EVM wallet address.');
    }

    final chainResult = await _rpc(
      network,
      'eth_chainId',
      const [],
    );

    if (chainResult is! String || !chainResult.startsWith('0x')) {
      throw const FormatException('Invalid blockchain chain ID.');
    }

    final actualChainId = int.parse(
      chainResult.substring(2),
      radix: 16,
    );

    if (actualChainId != network.chainId) {
      throw StateError(
        'Wrong blockchain network. Expected chain ID '
        '${network.chainId}, received $actualChainId.',
      );
    }

    final balanceResult = await _rpc(
      network,
      'eth_getBalance',
      [normalizedAddress, 'latest'],
    );

    if (balanceResult is! String ||
        !RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(balanceResult)) {
      throw const FormatException('Invalid native balance response.');
    }

    final balance = BigInt.parse(
      balanceResult.substring(2),
      radix: 16,
    );

    return EvmNativeBalance(
      network: network,
      address: normalizedAddress,
      rawBalance: balance,
    );
  }

  void dispose() {
    _client.close();
  }
}

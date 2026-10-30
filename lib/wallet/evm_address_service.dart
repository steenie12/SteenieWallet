import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';

import 'mnemonic_service.dart';

/// Derives public Ethereum-compatible addresses from BIP39 recovery phrases.
///
/// Never log or persist the derived private key.
class EvmAddressService {
  EvmAddressService({MnemonicService? mnemonicService})
      : _mnemonicService = mnemonicService ?? MnemonicService();

  final MnemonicService _mnemonicService;

  static const String derivationPath = "m/44'/60'/0'/0/0";

  /// Derives the first EVM address for Ethereum, BNB Chain, Polygon and Base.
  String deriveAddress(String recoveryPhrase) {
    final mnemonic =
        _mnemonicService.normalizeMnemonic(recoveryPhrase);

    if (!_mnemonicService.validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid BIP39 recovery phrase.');
    }

    final seed = bip39.mnemonicToSeed(mnemonic);
    Uint8List? privateKey;

    try {
      final root = bip32.BIP32.fromSeed(seed);
      final account = root.derivePath(derivationPath);

      privateKey = account.privateKey;

      if (privateKey == null || privateKey.length != 32) {
        throw StateError('Unable to derive a valid EVM private key.');
      }

      // Calculate the public address without exposing the private key.
      final credentials = EthPrivateKey(privateKey);
      return credentials.address.hexEip55;
    } finally {
      // Best-effort clearing of temporary byte buffers.
      seed.fillRange(0, seed.length, 0);
      privateKey?.fillRange(0, privateKey.length, 0);
    }
  }
}

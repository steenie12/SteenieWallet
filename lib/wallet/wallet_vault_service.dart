import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../core/security/wallet_crypto.dart';
import '../storage/secure_wallet_storage.dart';
import 'wallet_service.dart';

class WalletVault {
  const WalletVault({
    required this.mnemonic,
    required this.createdAt,
    required this.networkId,
    required this.walletId,
  });

  // Keep this object in memory only. Never log or persist it unencrypted.
  final String mnemonic;
  final DateTime createdAt;
  final String networkId;
  final String walletId;
}

class WalletVaultService {
  WalletVaultService({
    WalletCrypto? crypto,
    SecureWalletStorage? storage,
    WalletService? walletService,
  })  : _crypto = crypto ?? WalletCrypto(),
        _storage = storage ?? SecureWalletStorage(),
        _walletService = walletService ?? WalletService();

  final WalletCrypto _crypto;
  final SecureWalletStorage _storage;
  final WalletService _walletService;

  static const int _vaultVersion = 1;
  static const String _defaultNetwork = 'bitcoin-testnet';

  String _newWalletId() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<WalletVault> createWallet({
    required String password,
  }) async {
    if (await _storage.hasWallet()) {
      throw StateError('A wallet already exists. Unlock or restore separately.');
    }

    final phrase = _walletService.createRecoveryPhrase();
    return _saveWallet(phrase, password);
  }

  Future<WalletVault> importWallet({
    required String mnemonic,
    required String password,
  }) async {
    if (await _storage.hasWallet()) {
      throw StateError('A wallet already exists. Do not overwrite it.');
    }

    final normalized = _walletService.normalizeRecoveryPhrase(mnemonic);

    if (!_walletService.validateRecoveryPhrase(normalized)) {
      throw ArgumentError('The recovery phrase is invalid.');
    }

    return _saveWallet(normalized, password);
  }

  Future<WalletVault> _saveWallet(
    String mnemonic,
    String password,
  ) async {
    if (password.length < 12) {
      throw ArgumentError('Use a password of at least 12 characters.');
    }

    final now = DateTime.now().toUtc();
    final walletId = _newWalletId();

    final data = <String, dynamic>{
      'vaultVersion': _vaultVersion,
      'walletId': walletId,
      'createdAt': now.toIso8601String(),
      'networkId': _defaultNetwork,
      'mnemonic': mnemonic,
    };

    final encrypted = await _crypto.encrypt(
      plaintext: jsonEncode(data),
      password: password,
    );

    await _storage.saveEncryptedWallet(encrypted);

    return WalletVault(
      mnemonic: mnemonic,
      createdAt: now,
      networkId: _defaultNetwork,
      walletId: walletId,
    );
  }

  Future<WalletVault> unlockWallet({
    required String password,
  }) async {
    final encrypted = await _storage.readEncryptedWallet();

    if (encrypted == null || encrypted.isEmpty) {
      throw StateError('No saved wallet was found.');
    }

    final plaintext = await _crypto.decrypt(
      encryptedPayload: encrypted,
      password: password,
    );

    final decoded = jsonDecode(plaintext);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid wallet vault data.');
    }

    // Accept the original wallet format so existing encrypted wallets
    // remain restorable after this upgrade.
    final phrase = decoded['mnemonic'];

    if (phrase is! String ||
        !_walletService.validateRecoveryPhrase(phrase)) {
      throw const FormatException('The saved recovery phrase is invalid.');
    }

    final normalized = _walletService.normalizeRecoveryPhrase(phrase);
    final createdAtValue = decoded['createdAt'];
    final createdAt = createdAtValue is String
        ? DateTime.tryParse(createdAtValue)?.toUtc()
        : null;

    final walletIdValue = decoded['walletId'];
    final networkValue = decoded['networkId'] ?? decoded['network'];

    return WalletVault(
      mnemonic: normalized,
      createdAt: createdAt ?? DateTime.now().toUtc(),
      networkId: networkValue is String
          ? networkValue
          : _defaultNetwork,
      walletId: walletIdValue is String
          ? walletIdValue
          : 'legacy-wallet',
    );
  }


  Future<void> configurePin({
    required String pin,
    required String walletPassword,
  }) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain exactly six digits.');
    }

    final salt = List<int>.generate(
      16,
      (_) => Random.secure().nextInt(256),
    );

    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 600000,
      bits: 256,
    );

    final key = await algorithm.deriveKey(
      secretKey: SecretKey(pin.codeUnits),
      nonce: salt,
    );
    final verifier = await key.extractBytes();

    await _storage.saveWalletSalt(base64Encode(salt));
    await _storage.savePinVerifier(base64Encode(verifier));
    // flutter_secure_storage protects this credential using Android
    // secure storage. The PIN itself is never stored.
    await _storage.savePinUnlockPassword(walletPassword);
  }

  Future<WalletVault> unlockWithPin({required String pin}) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw ArgumentError('Enter your six-digit PIN.');
    }

    final saltText = await _storage.readWalletSalt();
    final verifierText = await _storage.readPinVerifier();
    final protectedPassword = await _storage.readPinUnlockPassword();

    if (saltText == null ||
        verifierText == null ||
        protectedPassword == null) {
      throw StateError('PIN unlock has not been configured.');
    }

    final salt = base64Decode(saltText);
    final expected = base64Decode(verifierText);

    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 600000,
      bits: 256,
    );

    final key = await algorithm.deriveKey(
      secretKey: SecretKey(pin.codeUnits),
      nonce: salt,
    );
    final actual = await key.extractBytes();

    var difference = actual.length ^ expected.length;
    for (var i = 0; i < actual.length && i < expected.length; i++) {
      difference |= actual[i] ^ expected[i];
    }

    if (difference != 0) {
      throw StateError('Incorrect PIN.');
    }

    return unlockWallet(password: protectedPassword);
  }

  Future<bool> hasWallet() => _storage.hasWallet();
}

import '../core/constants/network_constants.dart';
import '../models/wallet_account.dart';
import 'address_service.dart';
import 'mnemonic_service.dart';

class WalletService {
  WalletService({
    MnemonicService? mnemonicService,
    AddressService? addressService,
  })  : _mnemonicService = mnemonicService ?? MnemonicService(),
        _addressService = addressService ?? const AddressService();

  final MnemonicService _mnemonicService;
  final AddressService _addressService;

  /// Creates a new 12-word BIP39 phrase in memory.
  ///
  /// The caller must show a recovery warning and must not log the phrase.
  String createRecoveryPhrase() {
    return _mnemonicService.generateMnemonic();
  }

  bool validateRecoveryPhrase(String phrase) {
    return _mnemonicService.validateMnemonic(phrase);
  }

  String normalizeRecoveryPhrase(String phrase) {
    return _mnemonicService.normalizeMnemonic(phrase);
  }

  String bip44Path(BitcoinNetwork network) {
    return _addressService.bip44Path(network);
  }

  String bip84Path(BitcoinNetwork network) {
    return _addressService.bip84Path(network);
  }

  /// Creates only public account metadata from a verified address.
  /// It does not derive or invent an address.
  WalletAccount accountFromVerifiedAddress({
    required String id,
    required String name,
    required String address,
    required BitcoinNetwork network,
  }) {
    if (address.trim().isEmpty) {
      throw ArgumentError('A verified Bitcoin address is required.');
    }

    return WalletAccount(
      id: id,
      name: name,
      address: address.trim(),
      network: network,
    );
  }
}

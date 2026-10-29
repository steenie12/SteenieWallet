import '../core/constants/network_constants.dart';

class DerivedBitcoinAddress {
  final String address;
  final String derivationPath;
  final String addressType;

  const DerivedBitcoinAddress({
    required this.address,
    required this.derivationPath,
    required this.addressType,
  });
}

class AddressService {
  const AddressService();

  /// Standard BIP44 account path.
  String bip44Path(BitcoinNetwork network) {
    final coinType = network == BitcoinNetwork.mainnet ? 0 : 1;
    return "m/44'/$coinType'/0'/0/0";
  }

  /// Standard BIP84 account path for native SegWit.
  String bip84Path(BitcoinNetwork network) {
    final coinType = network == BitcoinNetwork.mainnet ? 0 : 1;
    return "m/84'/$coinType'/0'/0/0";
  }

  /// Standard BIP32 root path.
  String bip32RootPath() => 'm';

  /// Address derivation will be connected to the selected, supported
  /// Bitcoin key-derivation library and covered by known test vectors
  /// before the app uses the result for receiving or spending funds.
  DerivedBitcoinAddress createPlaceholder() {
    return const DerivedBitcoinAddress(
      address: '',
      derivationPath: '',
      addressType: 'Not derived yet',
    );
  }
}

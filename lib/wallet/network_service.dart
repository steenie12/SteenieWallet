import '../core/constants/network_constants.dart';

class NetworkService {
  BitcoinNetwork _currentNetwork = NetworkConstants.initialNetwork;
  String? _customApiBase;

  BitcoinNetwork get currentNetwork => _currentNetwork;

  String get networkName => NetworkConstants.nameFor(_currentNetwork);

  String get apiBase =>
      _customApiBase ?? NetworkConstants.apiFor(_currentNetwork);

  bool get isMainnet => _currentNetwork == BitcoinNetwork.mainnet;

  void selectNetwork(BitcoinNetwork network) {
    _currentNetwork = network;

    // A custom endpoint is specific to the selected network.
    // Clear it when switching networks to avoid accidental cross-network use.
    _customApiBase = null;
  }

  void setCustomApiBase(String? value) {
    if (value == null || value.trim().isEmpty) {
      _customApiBase = null;
      return;
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw ArgumentError(
        'Use a valid HTTPS API URL without embedded credentials.',
      );
    }

    _customApiBase = value.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  void resetCustomApiBase() {
    _customApiBase = null;
  }
}

import 'package:bip39/bip39.dart' as bip39;

class MnemonicService {
  /// Generates a BIP39 12-word recovery phrase.
  /// The bip39 library generates the entropy and checksum.
  String generateMnemonic() {
    return bip39.generateMnemonic(strength: 128);
  }

  /// Validates the BIP39 phrase format and checksum.
  bool validateMnemonic(String phrase) {
    final normalized = normalizeMnemonic(phrase);

    if (normalized.isEmpty) return false;

    return bip39.validateMnemonic(normalized);
  }

  /// Normalizes whitespace and letter case before validation.
  String normalizeMnemonic(String phrase) {
    return phrase
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .join(' ');
  }

  /// Returns the phrase as separate words for the confirmation screen.
  List<String> words(String phrase) {
    final normalized = normalizeMnemonic(phrase);

    if (!validateMnemonic(normalized)) {
      throw ArgumentError('Invalid BIP39 recovery phrase.');
    }

    return normalized.split(' ');
  }
}

import 'package:local_auth/local_auth.dart';

class PinService {
  PinService({LocalAuthentication? authentication})
      : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  /// Checks whether the device can perform biometric authentication.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _authentication.isDeviceSupported();
      final canCheck = await _authentication.canCheckBiometrics;
      final biometrics = await _authentication.getAvailableBiometrics();

      return supported && canCheck && biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Requests device biometric authentication.
  /// This does not encrypt or decrypt the wallet by itself.
  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await canUseBiometrics()) return false;

      return await _authentication.authenticate(
        localizedReason: 'Unlock VELARIO WALLET',
      );
    } catch (_) {
      return false;
    }
  }

  /// Basic PIN format validation only.
  /// Secure PIN verification will be implemented with wallet storage.
  bool isValidPinFormat(String pin) {
    return RegExp(r'^[0-9]{6,12}$').hasMatch(pin);
  }
}

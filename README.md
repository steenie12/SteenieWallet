# Steenie Wallet

An open-source cryptocurrency wallet project, starting with Bitcoin testnet.

## Status

Early development. Not production-ready. Do not use with real funds.

## Planned features

- Bitcoin testnet support
- BIP39 recovery phrase creation and restoration
- Verified Bitcoin address derivation
- Encrypted local wallet storage
- Receive addresses and QR codes
- Balance and transaction history
- Locally signed Bitcoin transactions
- Biometric unlocking
- Automated tests and cloud Android builds

## Security

Never share recovery phrases, private keys, passwords, or wallet backups.
Public blockchain services may see addresses and related queries.
This project has not undergone an independent security audit.

Use disposable testnet wallets only.

## Development

With a compatible Flutter SDK, run:

    flutter pub get
    flutter analyze
    flutter test
    flutter build apk --debug

The Android project scaffolding and cloud build workflow still need to be completed.

## License

No license has been selected yet.

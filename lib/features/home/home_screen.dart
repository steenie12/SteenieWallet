import 'package:flutter/material.dart';

import '../../wallet/evm_address_service.dart';
import '../../wallet/evm_mainnet_service.dart';
import '../../wallet/wallet_vault_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.vault});

  final WalletVault vault;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EvmMainnetService _service = EvmMainnetService();

  int _tab = 0;
  String? _address;
  String? _addressError;
  bool _loading = true;
  bool _hideBalances = false;
  final Map<String, EvmNativeBalance> _balances = {};
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final address = EvmAddressService().deriveAddress(
        widget.vault.mnemonic,
      );

      if (!mounted) return;
      setState(() {
        _address = address;
        _addressError = null;
      });

      await _refreshBalances();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addressError = 'Could not derive your EVM wallet address.';
        _loading = false;
      });
    }
  }

  Future<void> _refreshBalances() async {
    final address = _address;
    if (address == null) return;

    setState(() {
      _loading = true;
      _errors.clear();
    });

    for (final network in EvmMainnetNetwork.all) {
      try {
        final balance = await _service.fetchNativeBalance(
          network: network,
          address: address,
        );
        if (!mounted) return;
        setState(() => _balances[network.id] = balance);
      } catch (error) {
        if (!mounted) return;
        setState(() => _errors[network.id] = error.toString());
      }
    }

    if (mounted) setState(() => _loading = false);
  }


  void _copyAddress() {
    final address = _address;
    if (address == null) return;
    // Clipboard integration will be added to the receive screen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Your address: $address')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _walletPage(),
      _marketsPage(),
      _activityPage(),
      _settingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.candlestick_chart_outlined),
            selectedIcon: Icon(Icons.candlestick_chart),
            label: 'Markets',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _walletPage() {
    return RefreshIndicator(
      onRefresh: _refreshBalances,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'VELARIO',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton(
                tooltip: _hideBalances ? 'Show balances' : 'Hide balances',
                onPressed: () => setState(
                  () => _hideBalances = !_hideBalances,
                ),
                icon: Icon(
                  _hideBalances
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              IconButton(
                tooltip: 'Refresh balances',
                onPressed: _loading ? null : _refreshBalances,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Total portfolio',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _hideBalances ? '••••••••' : 'Live balances',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Native assets · Mainnet networks',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 22),
          _addressCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your assets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_loading)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_addressError != null)
            _errorCard(_addressError!)
          else
            ...EvmMainnetNetwork.all.map(_assetCard),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showActionMessage(
                    'Receive address',
                    'Use your EVM address above for supported EVM networks. '
                    'Always verify the network before depositing.',
                  ),
                  icon: const Icon(Icons.south_west),
                  label: const Text('Receive'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showActionMessage(
                    'Send crypto',
                    'Transaction signing and broadcasting are not enabled yet. '
                    'No funds can be sent from this screen.',
                  ),
                  icon: const Icon(Icons.north_east),
                  label: const Text('Send'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Balances are read from public blockchain RPC services. '
            'Token balances and fiat valuations are not included yet.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your EVM address',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  _address ?? 'Deriving address...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: _address == null ? null : _copyAddress,
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          const Text(
            'Same address on Ethereum, BNB, Polygon and Base.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _assetCard(EvmMainnetNetwork network) {
    final balance = _balances[network.id];
    final error = _errors[network.id];

    final amount = _hideBalances
        ? '••••••'
        : balance?.displayAmount ?? (error != null ? 'Unavailable' : 'Loading...');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF292B32),
          child: Text(
            network.symbol,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        title: Text(network.name),
        subtitle: Text(
          error == null
              ? 'Mainnet · Chain ID ${network.chainId}'
              : 'Balance unavailable · Tap refresh',
          style: const TextStyle(fontSize: 11, color: Colors.white54),
        ),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _marketsPage() {
    return _simplePage(
      Icons.candlestick_chart,
      'Markets',
      'Crypto market prices, charts and watchlists are the next market upgrade.',
    );
  }

  Widget _activityPage() {
    return _simplePage(
      Icons.receipt_long,
      'Activity',
      'Your transaction history will appear here when chain-specific history services are connected.',
    );
  }

  Widget _settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Wallet address'),
          subtitle: SelectableText(_address ?? 'Unavailable'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.security_outlined),
          title: Text('Self-custody security'),
          subtitle: Text('Recovery phrase encrypted on this device'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('Connected networks'),
          subtitle: Text('Ethereum · BNB · Polygon · Base'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Refresh balances'),
          onTap: _refreshBalances,
        ),
      ],
    );
  }

  Widget _simplePage(IconData icon, String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 55, color: const Color(0xFFF7931A)),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: const TextStyle(color: Colors.orangeAccent)),
      ),
    );
  }

  void _showActionMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../receive/receive_screen.dart';
import '../send/send_screen.dart';
import '../settings/settings_screen.dart';
import 'home_screen.dart';
import '../../wallet/wallet_vault_service.dart';

class WalletNavigation extends StatefulWidget {
  const WalletNavigation({super.key, required this.vault});

  final WalletVault vault;

  @override
  State<WalletNavigation> createState() => _WalletNavigationState();
}

class _WalletNavigationState extends State<WalletNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(vault: widget.vault),
    const ReceiveScreen(),
    const SendScreen(),
    const SettingsScreen(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.south_west_outlined),
      selectedIcon: Icon(Icons.south_west_rounded),
      label: 'Receive',
    ),
    NavigationDestination(
      icon: Icon(Icons.north_east_outlined),
      selectedIcon: Icon(Icons.north_east_rounded),
      label: 'Send',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

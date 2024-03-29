import 'package:flutter/material.dart';
import 'package:raven/pages/feed.dart';
import 'package:raven/pages/settings.dart';
import 'package:raven/pages/subscription.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Subscriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const FeedPage(),
          const SubscriptionsPage(),
          const SettingsPage(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
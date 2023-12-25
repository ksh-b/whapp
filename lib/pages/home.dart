import 'package:flutter/material.dart';
import 'package:whapp/pages/feed.dart';
import 'package:whapp/pages/subscription.dart';


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
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const FeedPage(),
          const SubscriptionsPage(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
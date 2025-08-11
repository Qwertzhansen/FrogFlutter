
import 'package:flutter/material.dart';
import 'package:frogg_flutter/src/presentation/screens/dashboard_screen.dart';
import 'package:frogg_flutter/src/presentation/screens/log_screen.dart';
import 'package:frogg_flutter/src/presentation/screens/community_screen.dart';
import 'package:frogg_flutter/src/presentation/screens/profile_screen.dart';
import 'package:frogg_flutter/src/presentation/screens/explore_screen.dart';
import 'package:frogg_flutter/src/services/sync_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _syncing = false;

  int get _tabCount => _widgetOptions.length;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    LogScreen(),
    ExploreScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      setState(() => _syncing = true);
      // Use mock user id; in prod use auth session id
      await SyncService.instance.trySyncAll('mock-user-id');
      if (!mounted) return;
      setState(() => _syncing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_syncing)
            const LinearProgressIndicator(minHeight: 2),
          BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mytodo/features/daily_notes/presentation/pages/daily_notes_page.dart';
import 'package:mytodo/features/settings/presentation/pages/settings_page.dart';
import 'package:mytodo/features/tasks/presentation/pages/task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const TaskPage(),
      const DailyNotesPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

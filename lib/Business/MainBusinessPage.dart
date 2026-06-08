import 'package:flutter/material.dart';

class MainBusinessPage extends StatefulWidget {
  const MainBusinessPage({super.key});

  @override
  State<MainBusinessPage> createState() => _MainBusinessPageState();
}

class _MainBusinessPageState extends State<MainBusinessPage> {
  int _selectedindex = 0;

  static final List<Widget> _pages = [
    Center(child: Text('DashboardPage')),
    Center(child: Text('AppointmentsPage')),
    Center(child: Text('Settings')),
    Center(child: Text('ProfilePage')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedindex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

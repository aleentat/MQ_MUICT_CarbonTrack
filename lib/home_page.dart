import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'travel_carbon_calculator.dart';
import 'waste_sorting_guide.dart';
import 'carbon_diary_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Home
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CarbonDiaryPage()),
        );
        break;
      case 3: // Statistics 
        break;
      case 4: // Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color(0xFFFCFAF2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
        child: Column(
          children: [
            Center(
              child: Text(
                'My Activity',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),
            Text(today, style: TextStyle(fontSize: 16)),
            SizedBox(height: 40),
            _buildButton(
              icon: Icons.directions_car,
              label: 'Travel Calculation',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TravelCarbonCalculator()),
              ),
            ),
            SizedBox(height: 20),
            _buildButton(
              icon: Icons.delete_outline,
              label: 'Waste Separation',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WasteSortingGuide()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Color(0xFF4C6A4F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(width: 20),
            Icon(icon, color: Colors.white),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: const Color.fromARGB(255, 192, 192, 192)),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.cases_rounded), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Statistic'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'carbon_diary_page.dart';
import 'statistic_page.dart';
import 'activity_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Map<String, String>> mockNews = [
    {
      "title": "Thailand sets goal to cut CO₂ emissions by 30% by 2030",
      "summary":
          "The government introduces a Net Zero policy for national sustainability.",
      "image": "assets/images/news1.jpeg",
      "url": "https://thailand.go.th/issue-focus-detail/--ndc--2573",
    },
    {
      "title": "New technology captures carbon directly from air",
      "summary":
          "Scientists develop Direct Air Capture (DAC) to fight climate change.",
      "image": "assets/images/news2.jpeg",
      "url":
          "https://phys.org/news/2025-06-ai-materials-capture-air.html#:~:text=In%20order%20to%20help%20prevent,the%20air—is%20gaining%20attention.",
    },
  ];

  final List<String> ecoTips = [
    "Carry a reusable water bottle instead of buying plastic bottles.",
    "Bring your own bag when shopping.",
    "Turn off lights when not in use.",
    "Use public transportation or bicycle when possible.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF2),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          ActivityPage(),
          CarbonDiaryPage(),
          StatisticPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          _buildWelcomeSection(),
          SizedBox(height: 30),
          _buildTipsSection(),
          SizedBox(height: 30),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFDFF3E3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Track your daily carbon footprint and help save the planet together',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/images/earth.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/tips_icon.png', height: 30),
            SizedBox(width: 10),
            Text(
              'Eco Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 10),
        Column(
          children:
              ecoTips.map((tip) {
                return Card(
                  color: Color.fromARGB(255, 253, 246, 209),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.eco, color: Colors.green[800]),
                    title: Text(tip, style: TextStyle(fontSize: 14)),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/news_icon.png', height: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Environmental News 📰',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Column(children: mockNews.map((news) => _buildNewsCard(news)).toList()),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, String> news) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(news['url'] ?? '');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                news['image']!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      news['summary']!,
                      style: TextStyle(fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.cases_rounded), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Statistic')
      ],
    );
  }
}
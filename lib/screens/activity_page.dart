import 'package:carbondiary/screens/eating_calculator.dart';
import 'package:carbondiary/screens/shopping_calculator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'travel_carbon_calculator.dart';
import 'waste_sorting_guide.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ActivityPageController extends State<ActivityPage> {
  void showTutorial();
  void checkActivityTutorial();
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  ActivityPageController createState() => _ActivityPageState();
}

class _ActivityPageState extends ActivityPageController {

  GlobalKey travelKey = GlobalKey();
  GlobalKey wasteKey = GlobalKey();
  GlobalKey shoppingKey = GlobalKey();
  GlobalKey eatingKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  void initTutorial() {
  targets = [

    TargetFocus(
      identify: "Travel",
      keyTarget: travelKey,
      shape: ShapeLightFocus.RRect,
      radius: 18, 
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Text(
            "Log your transportation carbon footprint here.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),

    TargetFocus(
      identify: "Waste",
      keyTarget: wasteKey,
      shape: ShapeLightFocus.RRect,
      radius: 18, 
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Text(
            "Learn how to sort waste and track its impact.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),

    TargetFocus(
      identify: "Shopping",
      keyTarget: shoppingKey,
      shape: ShapeLightFocus.RRect,
      radius: 18, 
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Text(
            "Track the carbon footprint of your purchases.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),

    TargetFocus(
      identify: "Eating",
      keyTarget: eatingKey,
      shape: ShapeLightFocus.RRect,
      radius: 18, 
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Text(
            "Estimate the carbon impact of your meals.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),

  ];
}

  @override
  void showTutorial() {
  initTutorial();
  tutorialCoachMark = TutorialCoachMark(
    targets: targets,
    textSkip: "SKIP",
    opacityShadow: 0.8,
  );

  tutorialCoachMark.show(context: context);
}
  
  @override
  Future<void> checkActivityTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seenActivityTutorial') ?? false;

  if (!seen) {
    showTutorial();
    await prefs.setBool('seenActivityTutorial', true);
  }
}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'My Activity',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          39,
                          76,
                          67,
                        ).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        today,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Text(
                'Choose an activity to log',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2, // 2 x 2 grid
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildActivityButton(
                  key: travelKey,
                  imagePath: 'assets/images/travel.png',
                  label: 'Travel',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TravelCarbonCalculator(),
                      ),
                    );
                  },
                ),
                _buildActivityButton(
                  key: wasteKey,
                  imagePath: 'assets/images/waste.png',
                  label: 'Waste',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WasteSortingGuide()),
                    );
                  },
                ),
                _buildActivityButton(
                  key: shoppingKey,
                  imagePath: 'assets/images/shop.png',
                  label: 'Shopping',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ShoppingCalculator()),
                    );
                  },
                ),
                _buildActivityButton(
                  key: eatingKey,
                  imagePath: 'assets/images/eat.png',
                  label: 'Eating',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EatingCalculator()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityButton({
    Key? key,
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.contain),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
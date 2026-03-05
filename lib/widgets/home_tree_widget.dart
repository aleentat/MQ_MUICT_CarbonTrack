import 'package:flutter/material.dart';
import '../models/weekly_eco_state.dart';

class HomeTreeWidget extends StatelessWidget {
  final TreeStage stage;

  const HomeTreeWidget({super.key, required this.stage});

  String _assetForStage() {
    switch (stage) {
      case TreeStage.dry:
        return 'assets/images/trees/drytree.png';
      case TreeStage.seed:
        return 'assets/images/trees/seed.png';
      case TreeStage.sprout:
        return 'assets/images/trees/sprout.png';
      case TreeStage.healthy:
        return 'assets/images/trees/tree.png';
      case TreeStage.blooming:
        return 'assets/images/trees/blooming.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetForStage(),
      height: 80,
      width: 80,
      fit: BoxFit.contain,
    );
  }
}

import 'package:flutter/material.dart';
import '../models/weekly_eco_state.dart';

class HomeTreeWidget extends StatelessWidget {
  final TreeStage stage;

  const HomeTreeWidget({super.key, required this.stage});

  String _assetForStage() {
    switch (stage) {
      case TreeStage.sprout:
        return 'assets/gif/tree_sprout.gif';
      case TreeStage.healthy:
        return 'assets/gif/tree_healthy.gif';
      case TreeStage.blooming:
        return 'assets/gif/tree_blooming.gif';
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

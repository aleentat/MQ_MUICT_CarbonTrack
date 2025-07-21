class TravelDiaryEntry {
  final String startLocation;
  final String endLocation;
  final String mode;
  final double distance;
  final double carbon;
  final DateTime timestamp;

  TravelDiaryEntry({
    required this.startLocation,
    required this.endLocation,
    required this.mode,
    required this.distance,
    required this.carbon,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'startLocation': startLocation,
      'endLocation': endLocation,
      'mode': mode,
      'distance': distance,
      'carbon': carbon,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TravelDiaryEntry.fromMap(Map<String, dynamic> map) {
    return TravelDiaryEntry(
      startLocation: map['startLocation'],
      endLocation: map['endLocation'],
      mode: map['mode'],
      distance: map['distance'],
      carbon: map['carbon'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
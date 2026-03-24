import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartTravelService {
  /// ===============================
  /// SINGLETON
  /// ===============================
  static final SmartTravelService _instance =
      SmartTravelService._internal();

  factory SmartTravelService() => _instance;

  SmartTravelService._internal();

  /// ===============================
  /// PREFS (TOGGLE)
  /// ===============================
  static const String _prefKey = "smart_travel_enabled";
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  /// ===============================
  /// LOCATION STREAM
  /// ===============================
  StreamSubscription<Position>? _positionStream;

  /// ===============================
  /// NOTIFICATION
  /// ===============================
  final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  /// ===============================
  /// MOVEMENT STATE
  /// ===============================
  Position? _lastPosition;
  DateTime? _lastMoveTime;
  bool _isMoving = false;

  /// ===============================
  /// TRIP STATE
  /// ===============================
  Position? _start;
  Position? _last;
  double _distance = 0;
  DateTime? _startTime;

  /// ===============================
  /// INIT
  /// ===============================
  Future<void> init() async {
    await _initNotification();

    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_prefKey) ?? false;

    if (_isEnabled) start();
  }

  /// ===============================
  /// TOGGLE
  /// ===============================
  Future<void> toggle(bool value) async {
    _isEnabled = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);

    if (value) {
      start();
    } else {
      stop();
    }
  }

  /// ===============================
  /// START / STOP
  /// ===============================
  Future<void> start() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 50,
      ),
    ).listen(_onLocationUpdate);
  }

  void stop() {
    _positionStream?.cancel();
  }

  /// ===============================
  /// LOCATION UPDATE
  /// ===============================
  void _onLocationUpdate(Position current) {
    if (_lastPosition == null) {
      _lastPosition = current;
      return;
    }

    double distance = _calcDistance(_lastPosition!, current);

    if (distance > 0.005) { // Change to 0.05 in production
      _lastMoveTime = DateTime.now();

      if (!_isMoving) {
        _isMoving = true;
        _startTrip(current);
      } else {
        _updateTrip(current);
      }
    } else {
      if (_isMoving &&
          _lastMoveTime != null &&
          DateTime.now().difference(_lastMoveTime!).inSeconds >= 10) { // Change to 2 inMinutes in production
        _isMoving = false;
        _endTrip();
      }
    }

    _lastPosition = current;
  }

  /// ===============================
  /// TRIP LOGIC
  /// ===============================
  void _startTrip(Position pos) {
    _start = pos;
    _last = pos;
    _distance = 0;
    _startTime = DateTime.now();
  }

  void _updateTrip(Position pos) {
    if (_last != null) {
      _distance += Geolocator.distanceBetween(
            _last!.latitude,
            _last!.longitude,
            pos.latitude,
            pos.longitude,
          ) /
          1000;
    }
    _last = pos;
  }

  void _endTrip() {
    if (_start == null || _startTime == null) return;

    final duration =
        DateTime.now().difference(_startTime!).inSeconds / 3600;

    double speed = duration > 0 ? _distance / duration : 0;

    if (_distance > 0.01) { // Change to 1 in production
      final transport = _detectTransport(speed);
      _showNotification(_distance, transport);
    }

    _reset();
  }

  void _reset() {
    _start = null;
    _last = null;
    _distance = 0;
    _startTime = null;
  }

  /// ===============================
  /// TRANSPORT ESTIMATION
  /// ===============================
  String _detectTransport(double speed) {
    if (speed < 5) return "Walking";
    if (speed < 20) return "Bike";
    return "Car";
  }

  /// ===============================
  /// NOTIFICATION
  /// ===============================
  Future<void> _initNotification() async {
    const android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notification.initialize(settings);
  }

  void _showNotification(double distance, String transport) async {
    const androidDetails = AndroidNotificationDetails(
      'trip_channel',
      'Trip Detection',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notification.show(
      0,
      "Trip detected 🚗",
      "You traveled ${distance.toStringAsFixed(1)} km ($transport). Log it in Travel page.",
      details,
    );
  }

  /// ===============================
  /// DISTANCE
  /// ===============================
  double _calcDistance(Position a, Position b) {
    const R = 6371;
    double dLat = _deg(b.latitude - a.latitude);
    double dLon = _deg(b.longitude - a.longitude);

    double lat1 = _deg(a.latitude);
    double lat2 = _deg(b.latitude);

    double x = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) *
            sin(dLon / 2) *
            cos(lat1) *
            cos(lat2);

    double c = 2 * atan2(sqrt(x), sqrt(1 - x));

    return R * c;
  }

  double _deg(double d) => d * pi / 180;
}
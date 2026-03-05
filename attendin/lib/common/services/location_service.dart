import 'package:geolocator/geolocator.dart';

class LocationService {
  // 1. Singleton Pattern (Ensures only one instance exists across the app)
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // 2. Mutable Settings for Mocking (Great for testing & demos!)
  bool isMocking = false;

  // Default mock location: University of Cincinnati (Baldwin Hall example)
  Position _mockPosition = Position(
    latitude: 39.1329,
    longitude: -84.5150,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

  // 3. Methods to Change Location at Runtime (For a debug slider/menu)
  void setMockLocation(double lat, double lng) {
    _mockPosition = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  void toggleMockMode(bool enabled) {
    isMocking = enabled;
  }

  // 4. The "Gatekeeper" - Requests OS permission safely
  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if GPS hardware is actually turned on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // GPS is off in device settings
    }

    // Check app-level permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // User hit "Deny"
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // User blocked app permanently
    }

    return true; // We are good to go!
  }

  // 5. The Main Getter (Used by your Check-In button)
  Future<Position?> getCurrentPosition() async {
    // If we are testing, bypass hardware checks and return fake data
    if (isMocking) {
      return _mockPosition;
    }

    // Otherwise, check real permissions and get real GPS
    final hasPermission = await handlePermission();
    if (!hasPermission) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    print(
        'User Location → Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    return position;
  }

  // 6. The Math - Calculate distance in meters (Wrapper for Geolocator)
  double getDistanceInMeters(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}

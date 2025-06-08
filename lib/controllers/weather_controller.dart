import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../connections/weather_api.dart';
import '../models/weather_info.dart';

class WeatherController {
  final WeatherApi _api = WeatherApi();

  Future<WeatherInfo> loadWeatherAuto() async {
    try {
      final position = await _determinePosition();

      final weather = await _api.fetchWeatherByCoordinates(position.latitude, position.longitude);

      return weather;
    } catch (e) {
      rethrow;
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Геолокація заборонена');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Геолокація назавжди заборонена');
    }

    return await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  // ignore: unused_element
  Future<String> _getCityFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Місто не знайдено: placemarks порожній');
      }

      final city = placemarks.first.locality;

      if (city == null || city.trim().isEmpty) {
        throw Exception('Місто не визначене (locality порожнє)');
      }

      return city.trim();
    } catch (e) {
      rethrow;
    }
  }
}

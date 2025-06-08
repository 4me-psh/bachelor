class WeatherInfo {
  final String city;
  final double temperature;
  final double feelsLikeTemperature;
  final double speedOfWind;
  final double humidity;
  final String condition;
  final String iconUrl;

  WeatherInfo({
    required this.city,
    required this.temperature,
    required this.feelsLikeTemperature,
    required this.speedOfWind,
    required this.humidity,
    required this.condition,
    required this.iconUrl,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
  final rawIcon = json['conditionIcon'] ?? '';
  final fixedIconUrl = rawIcon.startsWith('http') ? rawIcon : 'https:$rawIcon';

  return WeatherInfo(
    city: json['city'],
    temperature: (json['temperature'] as num).toDouble(),
    feelsLikeTemperature: (json['feelsLikeTemperature'] as num).toDouble(),
    speedOfWind: (json['speedOfWind'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    condition: json['weatherCondition'],
    iconUrl: fixedIconUrl,
  );
}

}

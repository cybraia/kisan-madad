import 'dart:math';
import 'mock_sensor_data.csv.dart';

class MockSensorData {
  static final Random _random = Random();
  static List<SensorData>? _cachedData;

  static SensorData getRandomData() {
    // Use cached data if available, otherwise generate new data
    if (_cachedData == null) {
      _cachedData = _parseCsvData();
    }

    // Return a random entry from the CSV data
    return _cachedData![_random.nextInt(_cachedData!.length)];
  }

  static List<SensorData> _parseCsvData() {
    final lines = csvData.split('\n');
    final data = <SensorData>[];

    // Skip header line
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        final values = line.split(',');
        if (values.length >= 5) {
          try {
            data.add(
              SensorData(
                soilMoisture: double.parse(values[0]),
                temperature: double.parse(values[1]),
                humidity: double.parse(values[2]),
                ph: double.parse(values[3]),
                weather: values[4],
              ),
            );
          } catch (e) {
            // Skip invalid lines
            continue;
          }
        }
      }
    }

    return data;
  }

  static SensorData generateRandomData() {
    return SensorData(
      soilMoisture: _random.nextDouble() * 60 + 10, // 10-70%
      temperature: _random.nextDouble() * 30 + 15, // 15-45°C
      humidity: _random.nextDouble() * 60 + 30, // 30-90%
      ph: _random.nextDouble() * 4 + 4.5, // 4.5-8.5
      weather: _getRandomWeather(),
    );
  }

  static String _getRandomWeather() {
    final weathers = ['Sunny', 'Cloudy', 'Rain expected', 'Storm'];
    return weathers[_random.nextInt(weathers.length)];
  }
}

class SensorData {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double ph;
  final String weather;

  SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.weather,
  });

  @override
  String toString() {
    return 'SensorData(soilMoisture: $soilMoisture%, temperature: ${temperature}°C, humidity: $humidity%, ph: $ph, weather: $weather)';
  }
}

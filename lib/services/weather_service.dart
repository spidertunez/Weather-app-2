import 'package:dio/dio.dart';

class WeatherService {
  final Dio dio;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey = '2ef891173650113862ce490045ffe435';

  WeatherService({required this.dio});

  Future<Map<String, dynamic>?> fetchWeather({required String cityName}) async {
    try {
      final currentWeatherResponse = await dio.get(
        '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric',
      );

      final forecastWeatherResponse = await dio.get(
        '$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric',
      );

      if (currentWeatherResponse.statusCode == 200 &&
          forecastWeatherResponse.statusCode == 200) {
        return {
          'currentWeather': currentWeatherResponse.data,
          'forecastWeather': forecastWeatherResponse.data['list'],
        };
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      print('Error in fetchWeather: $e');
      return null;
    }
  }
}

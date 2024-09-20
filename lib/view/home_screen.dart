import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/WeatherStateMang.dart';
import 'forecast_Card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.teal.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 5.0),
                      ),
                      fillColor: Colors.transparent,
                      hintText: 'Enter city name',
                      hintStyle: const TextStyle(color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          final cityName = _searchController.text.trim();
                          if (cityName.isNotEmpty) {
                            Provider.of<WeatherDataModel>(context,
                                    listen: false)
                                .updateCity(cityName);
                            _searchController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Consumer<WeatherDataModel>(
                  builder: (context, weatherDataModel, child) {
                    final cityName = weatherDataModel.city;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future:
                          Provider.of<WeatherService>(context, listen: false)
                              .fetchWeather(cityName: cityName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          final currentWeather =
                              WeatherModel.fromJson(data['currentWeather']);
                          final forecastWeather =
                              (data['forecastWeather'] as List)
                                  .map((item) => WeatherModel.fromJson(item))
                                  .toList();

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, MMM d').format(
                                          DateTime.parse(currentWeather.date)),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 25, color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentWeather.city,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${currentWeather.temp.toStringAsFixed(1)}°C',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 24, color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'H: ${currentWeather.maxTemp.toStringAsFixed(1)}°C, L: ${currentWeather.minTemp.toStringAsFixed(1)}°C',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'The Forecast for the Next 5 days every 3 hours:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: List.generate(forecastWeather.length,
                                    (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: ForecastTile(
                                        weatherModel: forecastWeather[index]),
                                  );
                                }),
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                              child: Text('No weather data available.'));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

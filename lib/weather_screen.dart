import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather([String cityName = 'Default City']) async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherMapAPIKey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                weather = getCurrentWeather(_cityController.text);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Enter City Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                    color: Colors.deepPurpleAccent,
                    width: 5.0,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(70.0)),
                  ),
                ),
              ),
          ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  setState(() {
                    weather = getCurrentWeather(_cityController.text);
                  });
                },
                child: const Text('Get Weather', style: TextStyle(color: Colors.white),),
              ),
            ),

          FutureBuilder(
              future: weather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 
          
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                      ),
                    ),
                  );
                }
          
                final data = snapshot.data!;
                final currentWeatherData = data['list'][0];
          
                final currentTemp = currentWeatherData['main']['temp'];
                final currentSky = currentWeatherData['weather'][0]['main'];
                final humidity = currentWeatherData['main']['humidity'];
                final pressure = currentWeatherData['main']['pressure'];
                final windSpeed = currentWeatherData['wind']['speed'];
          
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    // Temperature
                                    Text(
                                      '$currentTemp K',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    // Icon
                                    Icon(
                                        currentSky == 'Clear' ||
                                                currentSky == 'Sunny'
                                            ? Icons.sunny
                                            : Icons.cloud,
                                        size: 64),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    // Type of Weather
                                    Text(
                                      currentSky,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          
                      const SizedBox(
                        height: 20,
                      ),
          
                      // Weather Cards
                      // Text
                      const Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          
                      const SizedBox(
                        height: 5,
                      ),
          
                      // Cards
          
                      // ListView
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: 30,
                          itemBuilder: (context, index) {
                            final weatherData = data['list'][index + 1];
                            final hourlySky = weatherData['weather'][0]['main'];
                            final time = DateTime.parse(weatherData['dt_txt']);
                            final temperature =
                                weatherData['main']['temp'].toString();
          
                            return HourlyForecastItem(
                              time: DateFormat.j().format(time),
                              icon: hourlySky == 'Clouds' || hourlySky == 'Rain' ? Icons.cloud : Icons.sunny,
                              temperature: temperature,
                            );
                          },
                        ),
                      ),
          
                      const SizedBox(
                        height: 15,
                      ),
          
                      // Additional Info
                      // Text
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          
                      const SizedBox(
                        height: 8,
                      ),
          
                      // Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            title: 'Humidity',
                            value: humidity.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            title: 'Wind Speed',
                            value: windSpeed.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.thermostat,
                            title: 'Pressure',
                            value: pressure.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}

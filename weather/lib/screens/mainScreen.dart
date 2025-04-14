import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:weather/main.dart';
import 'package:weather/key.dart';

// Accuweather data/Api site


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  
// NOW varieble  -----------------------------
  num temperature = 0.0;
  int weatherIconkey = 0;
  String weatherText = "";
  double realFeel = 0;
  double windSpeed = 0;
  int uVindex = 0;
  int humidity = 0;
  bool isLoading = true;
  String moredetailsUri = '';

//12Hr Varieble  ---------------------------------
  int weatherIconkey12hr = 01;
  String timeString = '00';
  num temp_12hr = 00;
  List<Map<String, dynamic>> data12hr = [];

// 5 days

  List<Map<String, dynamic>> data5day = [];






  fetchCurrentCond() async {
    try {
      final uri =
          "http://dataservice.accuweather.com/currentconditions/v1/213384?apikey=$apiKey&details=true";
      final res = await http.get(Uri.parse(uri));
      final data = jsonDecode(res.body);
      Map<String, dynamic> weatherData = data[0];
      temperature = double.parse(
        (((weatherData["Temperature"])["Metric"])["Value"]).toString(),
      );
      weatherIconkey = weatherData["WeatherIcon"];
      weatherText = weatherData["WeatherText"];
      realFeel = double.parse(
        (((weatherData["RealFeelTemperature"])["Metric"])["Value"]).toString(),
      );
      windSpeed = (((weatherData["Wind"])["Speed"])["Metric"])["Value"];
      uVindex = weatherData["UVIndex"];
      humidity = weatherData["RelativeHumidity"];
      moredetailsUri = weatherData["Link"];
      setState(() {
        //  print(res.body);
      });
    } catch (e) {
      print("Error occured - ${e.toString()}");
    }
  }

  fetch12HrsData() async {
    final uri = "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/213384?apikey=$apiKey";
    final res = await http.get(Uri.parse(uri));
    List<dynamic> data = jsonDecode(res.body);
    for (var map in data) {
  int  weatherIconkey12hr = map["WeatherIcon"];
  String timeString = DateTime.parse(map["DateTime"])
      .toLocal()
      .hour
      .toString()
      .padLeft(2, '0'); 
  double  temp_12hr = 5/9*(map["Temperature"]["Value"] - 32);

    Map<String, dynamic> indexdata = {"wi" : weatherIconkey12hr, "t" : timeString, "temp" : temp_12hr };
    data12hr.add(indexdata);
    }
    
  }

  fetch5DayData() async {
    int weatherIconkey5Data = 01;
    String dayString = "01";
    num temp_5day = 00;
    final uri = "http://dataservice.accuweather.com/forecasts/v1/daily/5day/213384?apikey=$apiKey&details=true";
    final res = await http.get(Uri.parse(uri));
    final data = jsonDecode(res.body);
    List<dynamic> df = data["DailyForecasts"];
    
    for (var map in df) {
      weatherIconkey5Data = map["Day"]["Icon"];
      dayString = DateTime.parse(map["Date"].toString()).day.toString();
    double minitemp = 5/9*(map["Temperature"]["Minimum"]["Value"] -32);
    double maxtemp = 5/9*(map["Temperature"]["Minimum"]["Value"] -32);
    temp_5day = (minitemp + maxtemp) /2 ;

    Map<String, dynamic> data5d = {"wi" : weatherIconkey5Data, "d" : dayString, "temp" : temp_5day };
    data5day.add(data5d);
    }

    
  }

  Future<void> _launchUrl(String urlString) async {
  if (!await launchUrl(Uri.parse(urlString))) {
    throw Exception('Could not launch $urlString');
  }
}

  @override
  void initState() {
    super.initState();
    fetchCurrentCond();
    fetch12HrsData();
    fetch5DayData();
    setState(() {
    isLoading = false; // mostra i dati!
  });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Column(
              children: [
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "MyCity, Italia",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 239, 232),
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Now", style: TextStyle(fontSize: 14)),
                            Row(
                              children: [
                                Text(
                                  temperature.toString(),
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Image.network(
                                  "https://developer.accuweather.com/sites/default/files/${weatherIconkey.toString().padLeft(2, '0')}-s.png",
                                ),
                              ],
                            ),
                            Text("RealFeel $realFeel"),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(weatherText, style: TextStyle(fontSize: 20)),
                          Text("Humidity: $humidity %"),
                          Text("Wind: $windSpeed km/h"),
                          Text("UV Index: $uVindex "),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 239, 232),
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Next 12 Hours",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: data12hr.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Column(
                                children: [
                                  Text(data12hr[index]["t"], style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 8),
                                  Image.network(
                                    "https://developer.accuweather.com/sites/default/files/${data12hr[index]["wi"].toString().padLeft(2 , '0')}-s.png",
                                  ),
                                  SizedBox(height: 10),
                                  Text(data12hr[index]["temp"].toString().substring(0, 4), style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 239, 232),
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Next 5 Days",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 115,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: data5day.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Column(
                                children: [
                                  Text(data5day[index]["d"],
                                  style: TextStyle(fontSize: 10)),
                                  SizedBox(height: 3),
                                  Image.network(
                                    "https://developer.accuweather.com/sites/default/files/${data5day[index]["wi"].toString().padLeft(2 , '0')}-s.png",
                                  ),
                                  SizedBox(height: 3),
                                  Text(data5day[index]["temp"].toString().substring(0,4), style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {     
                        _launchUrl('https://developer.accuweather.com/');
                        }, child: Text("Accuweather")),
                    ElevatedButton(
                        onPressed: () {
                          _launchUrl(moredetailsUri);
                        }, child: Text("More Details")),
                  ],
                ),
              ],
            ),
          );
  }
}
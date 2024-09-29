import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/home_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class HomeClass extends StatefulWidget {
  const HomeClass({super.key});

  @override
  State<HomeClass> createState() => _HomeClassState();
}

class _HomeClassState extends State<HomeClass> {
  var key = "776f6b3b039b4a4fab8184902242509";
  String? address;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  getLatLong() {
    Future<Position> data = _determinePosition();
    data.then((value) {
      getAddress(value.latitude, value.longitude);
    }).catchError((error) {
      // ignore: invalid_return_type_for_catch_error
      return const SnackBar(content: Text("Error Fetching Location"));
    });
  }

  getAddress(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address = placemarks[0].locality;
    });
  }

  @override
  void initState() {
    getLatLong();
    Future.delayed(const Duration(seconds: 5));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchBoxController = TextEditingController();

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchBoxController,
                        onSubmitted: (value) {
                          setState(() {
                            address = value;
                          });
                        },
                        textInputAction: TextInputAction.go,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 20)),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            address = searchBoxController.text;
                          });
                          getWeatherResult(key, address);
                        },
                        child: const Icon(Iconsax.search_normal_1_copy)),
                    const SizedBox(width: 10)
                  ],
                ),
              ),
            ),
            FutureBuilder(
                future: getWeatherResult(key, address),
                builder:
                    (BuildContext context, AsyncSnapshot<HomeModel> snapshot) {
                  if (address != null) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      default:
                        if (snapshot.hasError) {
                          return Column(
                            children: [
                              const SizedBox(height: 50),
                              Image.asset("assets/images/noResult.png"),
                              const Text(
                                textAlign: TextAlign.center,
                                "No Result Found",
                                style: TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold),
                              )
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              const SizedBox(height: 40),
                              Image(
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "http:${snapshot.data?.icon ?? "https://cdn2.iconfinder.com/data/icons/weather-flat-14/64/weather02-512.png"}",
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    textAlign: TextAlign.center,
                                    snapshot.data?.name ?? "No Data",
                                    style: const TextStyle(
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Iconsax.location,
                                    color: Color.fromARGB(255, 2, 31, 86),
                                    size: 40,
                                  )
                                ],
                              ),
                              Text(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  "${snapshot.data?.region ?? "No Region"} | ${snapshot.data?.country ?? "No Country"}"),
                              Text(
                                "${snapshot.data?.tempC ?? "0"} \u2103",
                                style: const TextStyle(
                                    fontSize: 50, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${snapshot.data?.tempF ?? "0"} \u2109",
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                getDateAndDay(
                                    snapshot.data?.date ?? "2024-09-26 17:05"),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                snapshot.data?.conditionText ?? "No Condition",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const Divider(
                                height: 60,
                                indent: 35,
                                endIndent: 35,
                                thickness: 1.2,
                                color: Colors.black,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Iconsax.wind, size: 35),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${snapshot.data?.wind ?? "0"} km/h",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                                const Text("Wind",
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 25),
                                        Row(
                                          children: [
                                            const Icon(
                                              color: Colors.orange,
                                              Iconsax.sun_1_copy,
                                              size: 35,
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${snapshot.data?.uv ?? "0"}",
                                                    style: const TextStyle(
                                                        fontSize: 18)),
                                                const Text("UV",
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Iconsax.cloud_fog_copy,
                                                size: 35),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${snapshot.data?.cloud ?? "0"} %",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                                const Text("Cloud",
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 25),
                                        Row(
                                          children: [
                                            const Icon(
                                              color: Colors.blue,
                                              Icons.water_drop_outlined,
                                              size: 35,
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${snapshot.data?.humidity ?? "0"} %",
                                                    style: const TextStyle(
                                                        fontSize: 18)),
                                                const Text("Humidity",
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                })
          ],
        ),
      )),
    );
  }
}

Future<HomeModel> getWeatherResult(var key, String? name) async {
  var definedUrl =
      "http://api.weatherapi.com/v1/current.json?key=$key&q=$name&aqi=no";
  var url = Uri.parse(definedUrl);
  var response = await http.get(url);
  var responseBody = jsonDecode(response.body);
  return HomeModel.fromJson(responseBody);
}

String getDateAndDay(String inputDate) {
  DateTime dt = DateTime.parse(inputDate);
  String day = DateFormat('EEEE').format(dt);
  String date = DateFormat(' MMMM d').format(dt);
  return "$day |$date";
}

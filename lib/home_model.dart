class HomeModel {
  String? name;
  String? region;
  String? country;
  double? tempC;
  double? tempF;
  String? conditionText;
  String? icon;
  String? date;
  double? wind;
  num? humidity;
  num? cloud;
  double? uv;

  HomeModel({
    this.name,
    this.region,
    this.country,
    this.tempC,
    this.tempF,
    this.conditionText,
    this.icon,
    this.date,
    this.cloud,
    this.humidity,
    this.uv,
    this.wind,
  });

  HomeModel.fromJson(Map<String, dynamic> json) {
    name = json['location']['name'];
    region = json['location']['region'];
    country = json['location']['country'];
    date = json['location']['localtime'];
    tempC = json['current']['temp_c'];
    tempF = json['current']['temp_f'];
    conditionText = json['current']['condition']['text'];
    icon = json['current']['condition']['icon'];
    wind = json['current']['wind_kph'];
    humidity = json['current']['humidity'];
    cloud = json['current']['cloud'];
    uv = json['current']['uv'];
  }
}

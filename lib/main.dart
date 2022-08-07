import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рассчет координат',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Рассчет координат плиточной карты'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

late TextEditingController _controllerLat;
late TextEditingController _controllerLong;
late String x;
late String y;

late String _url;

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    _controllerLat.dispose();
    _controllerLong.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controllerLat = TextEditingController(text: "55.750626");
    _controllerLong = TextEditingController(text: "37.597664");

    x = _getX(37.597664);
    y = _getY(55.750626);

    _url =
        "https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${x}&y=${y}&z=19&scale=1&lang=ru_RU";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _controllerLat,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'lat',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _controllerLong,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'long',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue)),
                        onPressed: () {
                          getResult();
                        },
                        child: const Text("Найти плитку")),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Image(
              image: NetworkImage(_url),
            ),
          ),
          Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Text(
                      'X: $x',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Text(
                      'Y: $y',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  showMessage(context, String message) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void getResult() {
    if (_controllerLat.text.isEmpty) {
      showMessage(context, "Поле lat не может быть пустым");
      return;
    } else {}

    if (_controllerLong.text.isEmpty) {
      showMessage(context, "Поле long не может быть пустым");
      return;
    }

    double? lat = double.tryParse(_controllerLat.text);
    if (lat == null) {
      showMessage(context, "Поле lat должно быть числом");
      return;
    }
    double? long = double.tryParse(_controllerLong.text);
    if (long == null) {
      showMessage(context, "Поле long должно быть числом");
      return;
    }
    setState(() {
      x = _getX(long);
      y = _getY(lat);
      _url =
          "https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x&y=$y&z=19&scale=1&lang=ru_RU";
    });
    print(_url);
  }

  _levelZoom(z) {
    return (math.pow(2, z + 8) / 2);
  }

  _getX(double long) {
    return (((1 + (long / 180)) * _levelZoom(19)) / 256)
        .toString()
        .split(".")[0];
  }

  _getY(double lat) {
    return (((1 - (math.log(_getQ(lat))) / math.pi) * _levelZoom(19)) / 256)
        .toString()
        .split(".")[0];
  }

  final double _e = 0.0818191908426;
  double _getQ(double lat) {
    double b = ((math.pi * lat) / 180);

    double f = (1 - _e * math.sin(b)) / (1 + _e * math.sin(b));

    return math.tan(math.pi / 4 + b / 2) * math.pow(f, _e / 2);
  }
}

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart'; // Manejo de permisos

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IPInfoScreen(),
    );
  }
}

class IPInfoScreen extends StatefulWidget {
  @override
  _IPInfoScreenState createState() => _IPInfoScreenState();
}

class _IPInfoScreenState extends State<IPInfoScreen> {
  String? privateIP;
  String? publicIP;
  String? macOrBSSID;

  @override
  void initState() {
    super.initState();
    fetchNetworkDetails();
  }

  Future<void> fetchNetworkDetails() async {
    // Solicitar permisos de ubicación antes de obtener la información
    if (await Permission.location.request().isGranted) {
      final info = NetworkInfo();
      try {
        // Obtener la IP privada
        String? ip = await info.getWifiIP();
        // Obtener la MAC o el BSSID
        String? mac =
            await info.getWifiBSSID(); // Usamos BSSID como alternativa
        // Obtener la IP pública
        String? pubIP = await getPublicIP();

        setState(() {
          privateIP = ip ?? "No disponible";
          macOrBSSID = mac ?? "No disponible";
          publicIP = pubIP ?? "No disponible";
        });
      } catch (e) {
        setState(() {
          privateIP = "Error obteniendo datos";
          macOrBSSID = "Error obteniendo datos";
          publicIP = "Error obteniendo datos";
        });
      }
    } else {
      setState(() {
        privateIP = "Permiso denegado";
        macOrBSSID = "Permiso denegado";
        publicIP = "Permiso denegado";
      });
    }
  }

  Future<String?> getPublicIP() async {
    try {
      final response =
          await http.get(Uri.parse('https://api64.ipify.org?format=text'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print("Error obteniendo IP pública: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Información de Red"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IP Privada: ${privateIP ?? 'Cargando...'}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("IP Pública: ${publicIP ?? 'Cargando...'}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("MAC/BSSID: ${macOrBSSID ?? 'Cargando...'}",
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

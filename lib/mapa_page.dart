import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPage extends StatelessWidget {
  final double latitud;
  final double longitud;

  const MapaPage({
    super.key,
    required this.latitud,
    required this.longitud,
  });

  @override
  Widget build(BuildContext context) {
    final punto = LatLng(latitud, longitud);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa Real"),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: punto,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.clima_planificador",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: punto,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
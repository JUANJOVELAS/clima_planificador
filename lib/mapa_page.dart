import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapaPage extends StatefulWidget {
  final int usuarioId;
  final double latitud;
  final double longitud;

  const MapaPage({
    super.key,
    required this.usuarioId,
    required this.latitud,
    required this.longitud,
  });

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  LatLng? puntoSeleccionado;

  @override
  void initState() {
    super.initState();

    puntoSeleccionado = LatLng(
      widget.latitud,
      widget.longitud,
    );
  }

  Future<void> guardarUbicacion() async {
    if (puntoSeleccionado == null) return;

    final respuestaNombre = await http.get(
  Uri.parse(
    "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${puntoSeleccionado!.latitude}&lon=${puntoSeleccionado!.longitude}",
  ),
  headers: {
    "User-Agent": "clima_planificador",
  },
);

String nombreAutomatico = "Ubicación";

if (respuestaNombre.statusCode == 200) {
  final datosNombre = jsonDecode(respuestaNombre.body);

  nombreAutomatico =
      (datosNombre["display_name"] ?? "Ubicación")
          .toString()
          .split(',')
          .first;
}

    final nombreController = TextEditingController(
  text: nombreAutomatico,
);
    final descripcionController = TextEditingController();

    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guardar ubicación"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    final url = Uri.parse(
      "https://clima-planificador.onrender.com/ubicaciones",
    );

    final respuesta = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "usuario_id": widget.usuarioId,
        "nombre": nombreController.text.trim().isEmpty
            ? "Ubicación sin nombre"
            : nombreController.text.trim(),
        "descripcion": descripcionController.text.trim(),
        "latitud": puntoSeleccionado!.latitude,
        "longitud": puntoSeleccionado!.longitude,
      }),
    );

    if (respuesta.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ubicación guardada correctamente"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al guardar ubicación"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa Real"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: guardarUbicacion,
        icon: const Icon(Icons.save),
        label: const Text("Guardar ubicación"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            widget.latitud,
            widget.longitud,
          ),
          initialZoom: 16,
          onTap: (tapPosition, latlng) {
            setState(() {
              puntoSeleccionado = latlng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName:
                "com.example.clima_planificador",
          ),
          if (puntoSeleccionado != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: puntoSeleccionado!,
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
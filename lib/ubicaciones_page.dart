import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UbicacionesPage extends StatefulWidget {
  final int usuarioId;

  const UbicacionesPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<UbicacionesPage> createState() => _UbicacionesPageState();
}

class _UbicacionesPageState extends State<UbicacionesPage> {
  List ubicaciones = [];
    String filtroActual = "Recientes";

  Future<Map<String, dynamic>> obtenerClima(
  double latitud,
  double longitud,
) async {
  final url = Uri.parse(
    "https://api.open-meteo.com/v1/forecast?latitude=$latitud&longitude=$longitud&current_weather=true",
  );

  final respuesta = await http.get(url);

  if (respuesta.statusCode == 200) {
    final datos = jsonDecode(respuesta.body);

    return {
      "temperatura":
          datos["current_weather"]["temperature"].toString(),
      "viento":
          datos["current_weather"]["windspeed"].toString(),
    };
  }

  return {
    "temperatura": "--",
    "viento": "--",
  };
}

  Future<void> cargarUbicaciones() async {
    final url = Uri.parse(
      "https://clima-planificador.onrender.com/ubicaciones/${widget.usuarioId}",
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        ubicaciones = jsonDecode(respuesta.body);
      });
    }
  }
  Future<void> eliminarUbicacion(int id) async {
  final url = Uri.parse(
    "https://clima-planificador.onrender.com/ubicaciones/$id",
  );

  await http.delete(url);

  cargarUbicaciones();
}

  void ordenarRecientes() {
  setState(() {
    ubicaciones.sort(
      (a, b) => b["id"].compareTo(a["id"]),
    );
    filtroActual = "Recientes";
  });
}

void ordenarAntiguas() {
  setState(() {
    ubicaciones.sort(
      (a, b) => a["id"].compareTo(b["id"]),
    );
    filtroActual = "Antiguas";
  });
}

void ordenarNombre() {
  setState(() {
    ubicaciones.sort(
      (a, b) => a["nombre"]
          .toString()
          .toLowerCase()
          .compareTo(
            b["nombre"]
                .toString()
                .toLowerCase(),
          ),
    );
    filtroActual = "Nombre";
  });
}

  @override
  void initState() {
    super.initState();
    cargarUbicaciones();
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Ubicaciones"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                    Color(0xFF38BDF8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 55,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Mis Ubicaciones",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Consulta las coordenadas guardadas desde tu dispositivo.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: ordenarRecientes,
        icon: const Icon(Icons.new_releases),
        label: const Text("Recientes"),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: ElevatedButton.icon(
        onPressed: ordenarAntiguas,
        icon: const Icon(Icons.history),
        label: const Text("Antiguas"),
      ),
    ),
  ],
),

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: ordenarNombre,
    icon: const Icon(Icons.sort_by_alpha),
    label: const Text("Nombre"),
  ),
),

const SizedBox(height: 20),
            ubicaciones.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    
                    child: const Column(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 70,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "No hay ubicaciones guardadas",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Primero obtené y guardá una ubicación desde el inicio.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ubicaciones.length,
                    itemBuilder: (context, index) {
                      final ubicacion = ubicaciones[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.withOpacity(0.15),
                              child: const Icon(
                                Icons.place,
                                color: Colors.blue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
  child: FutureBuilder<Map<String, dynamic>>(
    future: obtenerClima(
      double.parse(ubicacion["latitud"].toString()),
      double.parse(ubicacion["longitud"].toString()),
    ),
    builder: (context, snapshot) {
      String temperatura = "...";
      String viento = "...";

      if (snapshot.hasData) {
        temperatura = snapshot.data!["temperatura"];
        viento = snapshot.data!["viento"];
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ubicacion["nombre"],
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            ubicacion["descripcion"] ?? "",
          ),

          const SizedBox(height: 10),

          Text(
            "🌡️ Temperatura: $temperatura °C",
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "💨 Viento: $viento km/h",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(
                  Icons.my_location,
                  size: 18,
                ),
                label: Text(
                  "Lat: ${ubicacion["latitud"]}",
                ),
              ),
              Chip(
                avatar: const Icon(
                  Icons.explore,
                  size: 18,
                ),
                label: Text(
                  "Lng: ${ubicacion["longitud"]}",
                ),
              ),
            ],
          ),
        ],
      );
    },
  ),
),
IconButton(
  icon: const Icon(
    Icons.delete,
    color: Colors.red,
  ),
  onPressed: () {
    eliminarUbicacion(
      ubicacion["id"],
    );
  },
),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
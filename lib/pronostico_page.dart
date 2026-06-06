import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PronosticoPage extends StatefulWidget {
  final double latitud;
  final double longitud;

  const PronosticoPage({
    super.key,
    required this.latitud,
    required this.longitud,
  });

  @override
  State<PronosticoPage> createState() => _PronosticoPageState();
}

class _PronosticoPageState extends State<PronosticoPage> {
  List fechas = [];
  List maximas = [];
  List minimas = [];


  List weatherCodes = [];
  Future<void> cargarPronostico() async {
   final url = Uri.parse(
  "https://api.open-meteo.com/v1/forecast?latitude=${widget.latitud}&longitude=${widget.longitud}&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto",
);

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      setState(() {
       fechas = datos["daily"]["time"];
       maximas = datos["daily"]["temperature_2m_max"];
       minimas = datos["daily"]["temperature_2m_min"];
        weatherCodes = datos["daily"]["weathercode"];
    });
    }
  }

  String recomendacion(double max, double min, String clima) {
  if (clima == "Tormenta") {
    return "Evitar actividades al aire libre";
  }

  if (clima == "Lluvia") {
    return "Llevar paraguas o impermeable";
  }

  if (clima == "Nublado") {
    return "Clima estable con poca radiación solar";
  }

  if (min <= 10) {
    return "Día frío, llevar abrigo";
  }

  if (max >= 25) {
    return "Día caluroso, hidratarse bien";
  }

  return "Buen clima para actividades";
}

  Color colorClima(double max, double min) {
    if (min <= 10) {
      return Colors.blue;
    } else if (max >= 25) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData iconoClima(double max, double min) {
    if (min <= 10) {
      return Icons.ac_unit;
    } else if (max >= 25) {
      return Icons.wb_sunny;
    } else {
      return Icons.cloud_queue;
    }
  }

  String estadoClima(int codigo) {
  if (codigo == 0) {
    return "Despejado";
  } else if (codigo >= 1 && codigo <= 3) {
    return "Nublado";
  } else if (codigo >= 51 && codigo <= 67) {
    return "Lluvia";
  } else if (codigo >= 71 && codigo <= 77) {
    return "Nieve";
  } else if (codigo >= 80 && codigo <= 99) {
    return "Tormenta";
  } else {
    return "Variable";
  }
}

  @override
  void initState() {
    super.initState();
    cargarPronostico();
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Pronóstico 7 días"),
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
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 55,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Pronóstico Climático",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Consulta temperaturas máximas, mínimas y recomendaciones para los próximos días.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            fechas.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(35),
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
                        CircularProgressIndicator(),
                        SizedBox(height: 18),
                        Text(
                          "Cargando pronóstico...",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fechas.length,
                    itemBuilder: (context, index) {
                      final max = maximas[index].toDouble();
                      final min = minimas[index].toDouble();
                      final color = colorClima(max, min);

                      final clima = weatherCodes.isNotEmpty
                      ? estadoClima(int.parse(weatherCodes[index].toString()))
                      : "Sin datos";

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
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(
                                iconoClima(max, min),
                                color: color,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fecha: ${fechas[index]}",
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        avatar: const Icon(
                                          Icons.arrow_upward,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        label: Text("Máx: $max °C"),
                                      ),
                                      Chip(
                                        avatar: const Icon(
                                          Icons.arrow_downward,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                        label: Text("Mín: $min °C"),
                                      ),
                                    ],
                                  ), 
                                  
                                  const SizedBox(height: 10),

                                     Text(
                                              "Estado: $clima",
                                             style: const TextStyle(
                                             fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                                   ),
                                           ),
 

                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      recomendacion(max, min,clima),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
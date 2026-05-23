import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PendientesPage extends StatefulWidget {
  final int usuarioId;

  const PendientesPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<PendientesPage> createState() => _PendientesPageState();
}

class _PendientesPageState extends State<PendientesPage> {
  List actividades = [];

  Future<void> cargarPendientes() async {
    final url = Uri.parse(
      "https://clima-planificador.onrender.com/actividades/${widget.usuarioId}",
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      setState(() {
        actividades = datos.where((a) {
          return a["estado"] == "Pendiente";
        }).toList();
      });
    }
  }

  String recomendacion(String tipo) {
    int probabilidad = tipo == "Aire libre" ? 65 : 90;

    if (probabilidad >= 80) {
      return "Probabilidad de realización: $probabilidad%\nActividad recomendada";
    } else {
      return "Probabilidad de realización: $probabilidad%\nConsultar clima antes de realizar";
    }
  }

  Color colorProbabilidad(String tipo) {
    int probabilidad = tipo == "Aire libre" ? 65 : 90;
    return probabilidad >= 80 ? Colors.green : Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    cargarPendientes();
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Actividades Pendientes"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF38BDF8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: Colors.white,
                    size: 52,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Pendientes Inteligentes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Consulta tus actividades pendientes con probabilidad de realización.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            actividades.isEmpty
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
                          Icons.check_circle,
                          size: 70,
                          color: Colors.green,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "No hay actividades pendientes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Todas tus actividades están completadas.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actividades.length,
                    itemBuilder: (context, index) {
                      final actividad = actividades[index];
                      final color = colorProbabilidad(actividad["tipo"]);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(
                                  Icons.cloud_queue,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      actividad["titulo"],
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(actividad["descripcion"]),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Chip(
                                          avatar: const Icon(
                                            Icons.calendar_month,
                                            size: 18,
                                          ),
                                          label: Text(actividad["fecha"]),
                                        ),
                                        Chip(
                                          avatar: const Icon(
                                            Icons.access_time,
                                            size: 18,
                                          ),
                                          label: Text(actividad["hora"]),
                                        ),
                                        Chip(
                                          avatar: const Icon(
                                            Icons.category,
                                            size: 18,
                                          ),
                                          label: Text(actividad["tipo"]),
                                        ),
                                      ],
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
                                        recomendacion(actividad["tipo"]),
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
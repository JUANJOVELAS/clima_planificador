import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class CalendarioPage extends StatefulWidget {
  final int usuarioId;

  const CalendarioPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  List actividades = [];

  DateTime diaSeleccionado = DateTime.now();
  DateTime diaEnfocado = DateTime.now();

  Future<void> cargarActividades() async {
    final url = Uri.parse(
      "http://127.0.0.1:5000/actividades/${widget.usuarioId}",
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        actividades = jsonDecode(respuesta.body);
      });
    }
  }

  List actividadesDelDia(DateTime dia) {
    return actividades.where((actividad) {
      DateTime fechaActividad = DateTime.parse(actividad["fecha"]);
      return fechaActividad.year == dia.year &&
          fechaActividad.month == dia.month &&
          fechaActividad.day == dia.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    cargarActividades();
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    final actividadesDia = actividadesDelDia(diaSeleccionado);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Calendario Visual"),
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
                    "Calendario de Actividades",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Visualiza tus actividades organizadas por fecha.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TableCalendar(
                focusedDay: diaEnfocado,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                selectedDayPredicate: (day) {
                  return isSameDay(diaSeleccionado, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    diaSeleccionado = selectedDay;
                    diaEnfocado = focusedDay;
                  });
                },
                eventLoader: (day) {
                  return actividadesDelDia(day);
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.event_note, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Actividades del día",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            actividadesDia.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Text(
                      "No hay actividades para este día.",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actividadesDia.length,
                    itemBuilder: (context, index) {
                      final actividad = actividadesDia[index];
                      final completada = actividad["estado"] == "Completada";

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
                          children: [
                            CircleAvatar(
                              backgroundColor: completada
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              child: Icon(
                                completada
                                    ? Icons.check_circle
                                    : Icons.pending_actions,
                                color: completada
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    actividad["titulo"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(actividad["descripcion"]),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Hora: ${actividad["hora"]} | Estado: ${actividad["estado"]}",
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

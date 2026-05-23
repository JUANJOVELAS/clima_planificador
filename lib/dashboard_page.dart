import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class DashboardPage extends StatefulWidget {
  final int usuarioId;

  const DashboardPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double promedio = 0;
  double maxima = 0;
  double minima = 0;

  List temperaturas = [];

  Future<void> cargarEstadisticas() async {
    final url = Uri.parse(
      "https://clima-planificador.onrender.com/estadisticas/${widget.usuarioId}",
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      setState(() {
        promedio = (datos["promedio"] ?? 0).toDouble();
        maxima = (datos["maxima"] ?? 0).toDouble();
        minima = (datos["minima"] ?? 0).toDouble();
      });
    }
  }

  Future<void> cargarTemperaturas() async {
    final url = Uri.parse(
      "https://clima-planificador.onrender.com/temperaturas/${widget.usuarioId}",
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        temperaturas = jsonDecode(respuesta.body);
      });
    }
  }

  Future<void> generarPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Reporte Estadístico del Clima",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Temperatura promedio: $promedio °C"),
              pw.Text("Temperatura máxima: $maxima °C"),
              pw.Text("Temperatura mínima: $minima °C"),
              pw.SizedBox(height: 20),
              pw.Text(
                "Historial de temperaturas",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...temperaturas.map((temp) {
                return pw.Text(
                  "${temp["fecha"]}  -  ${temp["temperatura"]} °C",
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
    cargarTemperaturas();
  }

  Widget tarjetaEstadistica(
    String titulo,
    String valor,
    IconData icono,
    Color color,
    Color card,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
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
            radius: 28,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              icono,
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
                  titulo,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> puntosGrafica() {
    List<FlSpot> puntos = [];

    for (int i = 0; i < temperaturas.length; i++) {
      puntos.add(
        FlSpot(
          i.toDouble(),
          temperaturas[i]["temperatura"].toDouble(),
        ),
      );
    }

    return puntos;
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Dashboard Estadístico"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generarPDF,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("PDF"),
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
                    Icons.analytics,
                    color: Colors.white,
                    size: 55,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Análisis Climático",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Promedio, máximas, mínimas y evolución de temperaturas registradas.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            tarjetaEstadistica(
              "Temperatura Promedio",
              "$promedio °C",
              Icons.show_chart,
              Colors.indigo,
              card,
            ),
            tarjetaEstadistica(
              "Temperatura Máxima",
              "$maxima °C",
              Icons.arrow_upward,
              Colors.red,
              card,
            ),
            tarjetaEstadistica(
              "Temperatura Mínima",
              "$minima °C",
              Icons.arrow_downward,
              Colors.blue,
              card,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.timeline,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Gráfica de Temperaturas",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 300,
                    child: temperaturas.isEmpty
                        ? const Center(
                            child: Text("No hay datos para graficar"),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: esOscuro
                                        ? Colors.white.withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.25),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(0),
                                        style: TextStyle(
                                          color: esOscuro
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 11,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: esOscuro
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 11,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: puntosGrafica(),
                                  isCurved: true,
                                  barWidth: 4,
                                  color: const Color(0xFF38BDF8),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFF38BDF8)
                                        .withOpacity(0.18),
                                  ),
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
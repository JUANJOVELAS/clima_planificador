import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ActividadesPage extends StatefulWidget {
  final int usuarioId;

  const ActividadesPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<ActividadesPage> createState() => _ActividadesPageState();
}

class _ActividadesPageState extends State<ActividadesPage> {
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final fechaController = TextEditingController();
  final horaController = TextEditingController();

  String tipo = "Aire libre";
  String mensaje = "";
  List actividades = [];
  int? actividadEditando;

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

  Future<void> guardarActividad() async {
    final url = Uri.parse("http://127.0.0.1:5000/actividades");

    final respuesta = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "usuario_id": widget.usuarioId,
        "ubicacion_id": 1,
        "titulo": tituloController.text,
        "descripcion": descripcionController.text,
        "fecha": fechaController.text,
        "hora": horaController.text,
        "tipo": tipo,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    setState(() {
      mensaje = datos["mensaje"] ?? datos["error"];
    });

    limpiarCampos();
    cargarActividades();
  }

  Future<void> completarActividad(int actividadId) async {
    final url = Uri.parse(
      "http://127.0.0.1:5000/actividades/$actividadId/completar",
    );

    await http.put(url);
    cargarActividades();
  }

  Future<void> eliminarActividad(int actividadId) async {
    final url = Uri.parse(
      "http://127.0.0.1:5000/actividades/$actividadId",
    );

    await http.delete(url);
    cargarActividades();
  }

  Future<void> editarActividad() async {
    final url = Uri.parse(
      "http://127.0.0.1:5000/actividades/$actividadEditando",
    );

    final respuesta = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "titulo": tituloController.text,
        "descripcion": descripcionController.text,
        "fecha": fechaController.text,
        "hora": horaController.text,
        "tipo": tipo,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    setState(() {
      mensaje = datos["mensaje"] ?? datos["error"];
      actividadEditando = null;
    });

    limpiarCampos();
    cargarActividades();
  }

  void cargarFormulario(Map actividad) {
    setState(() {
      actividadEditando = actividad["id"];
      tituloController.text = actividad["titulo"];
      descripcionController.text = actividad["descripcion"];
      fechaController.text = actividad["fecha"];
      horaController.text = actividad["hora"];
      tipo = actividad["tipo"];
    });
  }

  void limpiarCampos() {
    tituloController.clear();
    descripcionController.clear();
    fechaController.clear();
    horaController.clear();
  }

  InputDecoration inputDecoracion(String texto, IconData icono, bool esOscuro) {
    return InputDecoration(
      labelText: texto,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: esOscuro ? const Color(0xFF1E293B) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
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

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Actividades"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF38BDF8),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    actividadEditando == null
                        ? "Crear Actividad"
                        : "Editar Actividad",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Planifica tus tareas considerando clima, ubicación y estado.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(22),
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
              child: Column(
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: inputDecoracion("Título", Icons.title, esOscuro),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descripcionController,
                    decoration: inputDecoracion(
                      "Descripción",
                      Icons.description,
                      esOscuro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: fechaController,
                    decoration: inputDecoracion(
                      "Fecha: 2026-06-03",
                      Icons.calendar_month,
                      esOscuro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: horaController,
                    decoration: inputDecoracion(
                      "Hora: 14:30:00",
                      Icons.access_time,
                      esOscuro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tipo,
                    decoration: inputDecoracion("Tipo", Icons.category, esOscuro),
                    dropdownColor: card,
                    items: const [
                      DropdownMenuItem(
                        value: "Aire libre",
                        child: Text("Aire libre"),
                      ),
                      DropdownMenuItem(
                        value: "Interior",
                        child: Text("Interior"),
                      ),
                    ],
                    onChanged: (valor) {
                      setState(() {
                        tipo = valor!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: actividadEditando == null
                          ? guardarActividad
                          : editarActividad,
                      icon: Icon(
                        actividadEditando == null ? Icons.save : Icons.edit,
                      ),
                      label: Text(
                        actividadEditando == null
                            ? "Guardar actividad"
                            : "Actualizar actividad",
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  if (mensaje.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Actividades Guardadas",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            actividades.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      "No hay actividades registradas",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actividades.length,
                    itemBuilder: (context, index) {
                      final actividad = actividades[index];
                      final completada =
                          actividad["estado"] == "Completada";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          leading: CircleAvatar(
                            backgroundColor: completada
                                ? Colors.green.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            child: Icon(
                              completada
                                  ? Icons.check_circle
                                  : Icons.pending_actions,
                              color: completada ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            actividad["titulo"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "${actividad["descripcion"]}\n"
                              "Fecha: ${actividad["fecha"]}\n"
                              "Hora: ${actividad["hora"]}\n"
                              "Tipo: ${actividad["tipo"]}\n"
                              "Estado: ${actividad["estado"]}",
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () {
                                  cargarFormulario(actividad);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  eliminarActividad(actividad["id"]);
                                },
                              ),
                              if (!completada)
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  color: Colors.green,
                                  onPressed: () {
                                    completarActividad(actividad["id"]);
                                  },
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
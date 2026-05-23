import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PerfilPage extends StatefulWidget {
  final int usuarioId;

  const PerfilPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();

  String mensaje = "";
  String? fotoBase64;

  Future<void> cargarPerfil() async {
    final url = Uri.parse("http://127.0.0.1:5000/perfil/${widget.usuarioId}");

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      setState(() {
        nombreController.text = datos["nombre"];
        correoController.text = datos["correo"];
        fotoBase64 = datos["foto_perfil"];
      });
    }
  }

  Future<void> seleccionarFoto() async {
    final picker = ImagePicker();

    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (imagen != null) {
      final bytes = await imagen.readAsBytes();

      setState(() {
        fotoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> actualizarPerfil() async {
    final url = Uri.parse("http://127.0.0.1:5000/perfil/${widget.usuarioId}");

    final respuesta = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombreController.text,
        "correo": correoController.text,
        "foto_perfil": fotoBase64,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    setState(() {
      mensaje = datos["mensaje"] ?? datos["error"];
    });
  }

  ImageProvider imagenPerfil() {
    if (fotoBase64 != null && fotoBase64!.isNotEmpty) {
      Uint8List bytes = base64Decode(fotoBase64!);
      return MemoryImage(bytes);
    }

    return const AssetImage("assets/default_user.png");
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
    cargarPerfil();
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final fondo = esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF4F6FB);
    final card = esOscuro ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text("Perfil"),
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
                    Color(0xFF38BDF8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.white,
                    backgroundImage: fotoBase64 != null && fotoBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(fotoBase64!))
                        : null,
                    child: fotoBase64 == null || fotoBase64!.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 80,
                          )
                        : null,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Perfil de Usuario",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Visualiza y actualiza tus datos personales",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: seleccionarFoto,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Seleccionar foto"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
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
                    controller: nombreController,
                    decoration: inputDecoracion("Nombre", Icons.badge, esOscuro),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: correoController,
                    decoration: inputDecoracion("Correo", Icons.email, esOscuro),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: actualizarPerfil,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        "Guardar cambios",
                        style: TextStyle(fontSize: 16),
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
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
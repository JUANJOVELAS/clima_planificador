import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CambiarPasswordPage extends StatefulWidget {
  final int usuarioId;

  const CambiarPasswordPage({
    super.key,
    required this.usuarioId,
  });

  @override
  State<CambiarPasswordPage> createState() => _CambiarPasswordPageState();
}

class _CambiarPasswordPageState extends State<CambiarPasswordPage> {
  final nuevaController = TextEditingController();
  final confirmarController = TextEditingController();

  String mensaje = "";
  bool ocultarNueva = true;
  bool ocultarConfirmar = true;

  Future<void> cambiarPassword() async {
    final url = Uri.parse(
      "http://127.0.0.1:5000/cambiar-password/${widget.usuarioId}",
    );

    final respuesta = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nueva": nuevaController.text,
        "confirmar": confirmarController.text,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200) {
      Navigator.pop(context);
    } else {
      setState(() {
        mensaje = datos["error"];
      });
    }
  }

  InputDecoration inputDecoracion(String texto, IconData icono) {
    return InputDecoration(
      labelText: texto,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Cambiar contraseña"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 430,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_reset, size: 70, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Cambio obligatorio",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Debes cambiar tu contraseña temporal.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: nuevaController,
                obscureText: ocultarNueva,
                decoration: inputDecoracion("Nueva contraseña", Icons.lock)
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarNueva ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarNueva = !ocultarNueva;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: confirmarController,
                obscureText: ocultarConfirmar,
                decoration:
                    inputDecoracion("Confirmar contraseña", Icons.lock_outline)
                        .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarConfirmar
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarConfirmar = !ocultarConfirmar;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: cambiarPassword,
                  child: const Text("Cambiar contraseña"),
                ),
              ),
              if (mensaje.isNotEmpty) ...[
                const SizedBox(height: 15),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
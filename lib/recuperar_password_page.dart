import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final correoController = TextEditingController();
  String mensaje = "";

  Future<void> recuperar() async {
    final url = Uri.parse("http://127.0.0.1:5000/recuperar-password");

    final respuesta = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correoController.text,
      }),
    );

    final datos = jsonDecode(respuesta.body);

    setState(() {
      if (respuesta.statusCode == 200) {
        mensaje =
            "${datos["mensaje"]}\nContraseña temporal: ${datos["password_temporal"]}";
      } else {
        mensaje = datos["error"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(
                labelText: "Correo registrado",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: recuperar,
              child: const Text("Generar contraseña temporal"),
            ),
            const SizedBox(height: 20),
            Text(
              mensaje,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
